import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;
import '../../constants/api_constants.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/auth_service.dart';

class MicrosoftAuthService {
  // ── Build Microsoft OAuth URL ──────────────────────────────
  static String _buildAuthUrl() {
    final params = {
      'client_id': ApiConstants.microsoftClientId,
      'response_type': 'token',
      'redirect_uri': ApiConstants.microsoftRedirectUri,
      'scope': 'openid profile email User.Read',
      'response_mode': 'fragment',
    };
    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return 'https://login.microsoftonline.com/${ApiConstants.microsoftTenantId}/oauth2/v2.0/authorize?$query';
  }

  // ── Sign in with Microsoft (Flutter Web) ──────────────────
  static Future<void> signIn(BuildContext context) async {
    try {
      final authUrl = _buildAuthUrl();

      // Open Microsoft login popup
      final popup = web.window.open(
        authUrl,
        'microsoft_login',
        'width=500,height=600,scrollbars=yes',
      );

      // Poll popup for token then handle result
      final token = await _pollPopupForToken(popup);

      if (token != null && context.mounted) {
        await _handleToken(token, context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.microsoftLoginFailed),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Poll popup — returns token string or null ──────────────
  static Future<String?> _pollPopupForToken(web.Window? popup) async {
    if (popup == null) return null;

    for (int i = 0; i < 300; i++) {
      await Future.delayed(const Duration(seconds: 1));

      try {
        if (popup.closed) return null;

        final popupUrl = popup.location.href;
        if (popupUrl.contains('access_token=')) {
          final uri = Uri.parse(popupUrl.replaceFirst('#', '?'));
          final token = uri.queryParameters['access_token'];
          if (token != null && token.isNotEmpty) {
            popup.close();
            return token;
          }
        }
      } catch (_) {
        // Cross-origin — still on Microsoft page, keep polling
      }
    }
    return null;
  }

  // ── Handle token — send to backend ────────────────────────
  static Future<void> _handleToken(
      String microsoftToken, BuildContext context) async {
    try {
      final authService = AuthService();
      final response = await authService.signInWithMicrosoft(
        microsoftToken: microsoftToken,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.token);
      await prefs.setString('user_email', response.user.email);
      await prefs.setString('user_name', response.user.fullName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed in as ${response.user.email}'),
            backgroundColor: AppColors.primary,
          ),
        );
        // Navigate to home screen once built:
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.microsoftLoginFailed),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Sign out ───────────────────────────────────────────────
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    web.window.location.href =
        'https://login.microsoftonline.com/${ApiConstants.microsoftTenantId}/oauth2/v2.0/logout'
        '?post_logout_redirect_uri=${ApiConstants.microsoftRedirectUri}';
  }
}