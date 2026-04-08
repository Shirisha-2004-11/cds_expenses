// lib/services/auth_state.dart
// Simple in-memory token store — holds the JWT after login.
//
// This is the single source of truth for the token at runtime.
// It is populated in two places:
//   1. main()            — re-hydrated from SharedPreferences on cold start / page refresh.
//   2. sign_in_screen    — set immediately after a successful login response.
//
// ApiConfig.authHeaders reads from here first (synchronous, no async needed),
// falling back to SharedPreferences only if the in-memory value is empty.

import 'package:flutter/foundation.dart';
class AuthState {
  static String? _token;
  static String? _userName;
  static String? _userEmail;
  static String? _userId;

  static void setToken(String token, {String? userName, String? userEmail, String? userId}) {
    _token     = token;
    _userName  = userName;
    _userEmail = userEmail;
    _userId    = userId;

    // ── Console log all credentials after login ──
    debugPrint('╔══════════════════════════════════════════');
    debugPrint('║  LOGIN CREDENTIALS SAVED');
    debugPrint('╠══════════════════════════════════════════');
    debugPrint('║  User Name  : $_userName');
    debugPrint('║  User Email : $_userEmail');
    debugPrint('║  JWT Token  : $_token');
    debugPrint('╚══════════════════════════════════════════');
  }

  static String? get token     => _token;
  static String? get userName  => _userName;
  static String? get userEmail => _userEmail;
  static String? get userId    => _userId;

  static bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  static void clear() {
    _token     = null;
    _userName  = null;
    _userEmail = null;
    _userId    = null;
  }
}