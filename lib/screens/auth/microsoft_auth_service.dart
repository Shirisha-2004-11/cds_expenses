import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;
import '../../constants/api_constants.dart';
import '../../colors/app_colors.dart';
import '../../services/auth_service.dart';
import 'package:cds_expenses/dashboard_path/dashboard.dart';

class MicrosoftAuthService {
  // ── Build Microsoft OAuth URL ──────────────────────────────
  // Request BOTH token and id_token so we can decode user info
  static String _buildAuthUrl() {
    final params = {
      'client_id': ApiConstants.microsoftClientId,
      'response_type': 'token id_token',        // ← id_token has name+email
      'redirect_uri': ApiConstants.microsoftRedirectUri,
      'scope': 'openid profile email User.Read',
      'response_mode': 'fragment',
      'prompt': 'select_account',
      'nonce': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return 'https://login.microsoftonline.com/${ApiConstants.microsoftTenantId}/oauth2/v2.0/authorize?$query';
  }

  // ── Sign in with Microsoft ─────────────────────────────────
  static Future<void> signIn(BuildContext context) async {
    try {
      final authUrl = _buildAuthUrl();
      debugPrint('Opening Microsoft login popup...');

      final popup = web.window.open(
        authUrl,
        'microsoft_login',
        'width=500,height=700,scrollbars=yes,resizable=yes',
      );

      if (popup == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Popup blocked! Allow popups for localhost:4200 in Chrome.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      final completer = Completer<Map<String, String?>>();

      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (completer.isCompleted) {
          timer.cancel();
          return;
        }

        try {
          if (popup.closed) {
            debugPrint('Popup closed by user');
            timer.cancel();
            if (!completer.isCompleted) completer.complete({});
            return;
          }

          final popupUrl = popup.location.href;
          if (popupUrl.isEmpty || popupUrl == 'about:blank') return;

          // Parse both access_token and id_token from fragment
          if (popupUrl.contains('access_token=') || popupUrl.contains('id_token=')) {
            final fragment = popupUrl.contains('#')
                ? popupUrl.substring(popupUrl.indexOf('#') + 1)
                : popupUrl;

            final params = Uri.splitQueryString(fragment);
            final accessToken = params['access_token'];
            final idToken = params['id_token'];

            debugPrint('✅ Tokens received!');
            debugPrint('  access_token length: ${accessToken?.length}');
            debugPrint('  id_token length: ${idToken?.length}');

            timer.cancel();
            popup.close();
            if (!completer.isCompleted) {
              completer.complete({
                'access_token': accessToken,
                'id_token': idToken,
              });
            }
          }

          // Check for error
          if (popupUrl.contains('error=')) {
            final fragment = popupUrl.contains('#')
                ? popupUrl.substring(popupUrl.indexOf('#') + 1)
                : popupUrl;
            final params = Uri.splitQueryString(fragment);
            final error = params['error_description'] ?? params['error'] ?? 'Unknown';
            debugPrint('❌ Microsoft error: $error');
            timer.cancel();
            popup.close();
            if (!completer.isCompleted) completer.complete({});
          }
        } catch (_) {
          // Cross-origin — still on Microsoft page, keep polling
        }
      });

      // Timeout after 5 minutes
      Future.delayed(const Duration(minutes: 5), () {
        if (!completer.isCompleted) {
          debugPrint('⏱ Polling timed out');
          completer.complete({});
        }
      });

      final tokens = await completer.future;
      final accessToken = tokens['access_token'];
      final idToken = tokens['id_token'];

      if ((accessToken != null && accessToken.isNotEmpty) ||
          (idToken != null && idToken.isNotEmpty)) {
        if (context.mounted) {
          await _handleTokens(
            accessToken: accessToken,
            idToken: idToken,
            context: context,
          );
        }
      } else {
        debugPrint('No tokens received');
      }
    } catch (e) {
      debugPrint('Microsoft login error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Microsoft login failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Handle tokens — decode id_token for user info ─────────
  static Future<void> _handleTokens({
    String? accessToken,
    String? idToken,
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save raw tokens
    if (accessToken != null) {
      await prefs.setString('auth_token', accessToken);
      await prefs.setString('microsoft_token', accessToken);
    }
    if (idToken != null) {
      await prefs.setString('id_token', idToken);
    }

    // Decode id_token (contains name + email reliably)
    String name = '';
    String email = '';

    // Try id_token first — it always has name and email
    if (idToken != null && idToken.isNotEmpty) {
      final idClaims = _decodeJwt(idToken);
      if (idClaims != null) {
        name = idClaims['name']?.toString() ?? '';
        email = idClaims['email']?.toString() ??
            idClaims['preferred_username']?.toString() ??
            idClaims['unique_name']?.toString() ?? '';
        debugPrint('✅ From id_token: name=$name | email=$email');
      }
    }

    // Fallback: try access_token if id_token didn't have the info
    if ((name.isEmpty || email.isEmpty) && accessToken != null) {
      final accessClaims = _decodeJwt(accessToken);
      if (accessClaims != null) {
        if (name.isEmpty) name = accessClaims['name']?.toString() ?? '';
        if (email.isEmpty) {
          email = accessClaims['email']?.toString() ??
              accessClaims['preferred_username']?.toString() ??
              accessClaims['unique_name']?.toString() ?? '';
        }
        debugPrint('✅ From access_token: name=$name | email=$email');
      }
    }

    // Save to SharedPreferences
    if (name.isNotEmpty) await prefs.setString('user_name', name);
    if (email.isNotEmpty) await prefs.setString('user_email', email);

    debugPrint('✅ Saved to local storage:');
    debugPrint('  user_name  = $name');
    debugPrint('  user_email = $email');
    debugPrint('  auth_token = ${accessToken?.substring(0, 20)}...');

    // Try backend (works once CORS is fixed)
    try {
      if (accessToken != null) {
        final authService = AuthService();
        final response = await authService.signInWithMicrosoft(
          microsoftToken: accessToken,
        );
        await prefs.setString('auth_token', response.token);
        await prefs.setString('user_email', response.user.email);
        await prefs.setString('user_name', response.user.fullName);
        debugPrint('✅ Backend token saved');
      }
    } catch (e) {
      debugPrint('⚠️ Backend not reachable (CORS pending): $e');
    }

    if (context.mounted) {
      final savedName = prefs.getString('user_name') ?? 'User';
      final savedEmail = prefs.getString('user_email') ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome $savedName${savedEmail.isNotEmpty ? " ($savedEmail)" : ""}! ✅'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 4),
        ),
      );
      // Navigate to Dashboard screen
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen()));
    }
  }

  // ── Decode JWT using dart:convert (proper base64) ─────────
  static Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;

      // Fix base64url encoding → standard base64
      var payload = parts[1]
          .replaceAll('-', '+')
          .replaceAll('_', '/');

      // Add padding
      switch (payload.length % 4) {
        case 2: payload += '=='; break;
        case 3: payload += '='; break;
        default: break;
      }

      // Decode using dart:convert
      final decoded = utf8.decode(base64.decode(payload));
      debugPrint('JWT payload: $decoded');

      final json = jsonDecode(decoded) as Map<String, dynamic>;
      debugPrint('JWT fields: ${json.keys.toList()}');
      return json;
    } catch (e) {
      debugPrint('JWT decode error: $e');
      return null;
    }
  }

  // ── Sign out ──────────────────────────────────────────────
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    web.window.location.href =
        'https://login.microsoftonline.com/${ApiConstants.microsoftTenantId}/oauth2/v2.0/logout'
        '?post_logout_redirect_uri=${ApiConstants.microsoftRedirectUri}';
  }
}