// ─────────────────────────────────────────────────────────────────────────────
// lib/constants/api_config.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_state.dart';

class ApiConfig {
  // 🌐 Backend base URLs
  static const String authBaseUrl      = 'http://192.168.182.180:8081';
  static const String expenseBaseUrl   = 'http://192.168.182.180:8082';
  static const String dashboardBaseUrl = 'http://192.168.182.180:8083';

  // ── Auth endpoints (port 8081) ────────────────────────────────────────────
  static const String signIn         = '$authBaseUrl/auth/login';
  static const String signUp         = '$authBaseUrl/auth/register';
  static const String forgotPassword = '$authBaseUrl/auth/forgot-password';

  // ── Expense endpoints (port 8082) ─────────────────────────────────────────
  static const String expenses   = '$expenseBaseUrl/expenses';
  static const String categories = '$expenseBaseUrl/categories';

  // ── Dashboard endpoints (port 8083) ───────────────────────────────────────
  static const String budgetSummary    = '$dashboardBaseUrl/dashboard/summary';
  static const String insights         = '$dashboardBaseUrl/dashboard/insights';
  static const String recentExpenses   = '$dashboardBaseUrl/dashboard/recent-expenses';
  static const String dailyChart       = '$dashboardBaseUrl/dashboard/monthly-trend';
  static const String spendingInsights = '$dashboardBaseUrl/dashboard/insights';

  // ── Authenticated headers ─────────────────────────────────────────────────
  //
  // ✅ FIX: We now read from AuthState (in-memory) first.
  //         This avoids the async race condition where DashboardService.fetchAll()
  //         is called immediately after Navigator.pushReplacement() in sign_in_screen,
  //         before SharedPreferences.setString() has fully persisted the token.
  //
  //         Priority order:
  //           1. AuthState.token         — in-memory, set at login, instant (no await)
  //           2. SharedPreferences       — persisted on disk/localStorage, used as
  //                                        fallback on cold start / page refresh
  //                                        (main() should already have loaded this
  //                                         into AuthState, but we keep the fallback
  //                                         here as a safety net)
  static Future<Map<String, String>> get authHeaders async {
    // 1️⃣ Try in-memory store first — synchronous, always up-to-date after login
    String token = AuthState.token ?? '';

    // 2️⃣ Fall back to SharedPreferences (cold start safety net)
    if (token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token') ?? '';

      // Re-hydrate in-memory store so subsequent calls skip SharedPreferences
      if (token.isNotEmpty) {
        AuthState.setToken(token);
      }
    }

    // Debug log — remove in production
    if (token.isEmpty) {
      debugPrint('⚠️ WARNING: auth_token is empty! User may not be logged in.');
    } else {
      debugPrint('✅ Token found: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    }

    return {
      'Content-Type': 'application/json',
      'Accept'      : 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Public headers — for login / register (no token needed) ──────────────
  static Map<String, String> get publicHeaders => {
    'Content-Type': 'application/json',
    'Accept'      : 'application/json',
  };
}