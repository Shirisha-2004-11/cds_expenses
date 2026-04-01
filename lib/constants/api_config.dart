// ─────────────────────────────────────────────────────────────────────────────
// lib/config/api_config.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // 🌐 Backend base URLs
  static const String authBaseUrl    = 'http://192.168.182.180:8081';
  static const String expenseBaseUrl = 'http://192.168.182.180:8082';
  static const String dashboardBaseUrl = 'http://192.168.182.180:8083';

  // ── Auth endpoints (port 8081) ────────────────────────────────────────────
  static const String signIn         = '$authBaseUrl/auth/login';
  static const String signUp         = '$authBaseUrl/auth/register';
  static const String forgotPassword = '$authBaseUrl/auth/forgot-password';

  // ── Expense endpoints (port 8082) ─────────────────────────────────────────
  static const String expenses   = '$expenseBaseUrl/expenses';
  static const String categories = '$expenseBaseUrl/categories';

  // ── Dashboard endpoints (port 8083) ───────────────────────────────────────
  static const String budgetSummary    = '$dashboardBaseUrl/budget/summary';
  static const String insights         = '$dashboardBaseUrl/insights';
  static const String recentExpenses   = '$dashboardBaseUrl/expenses/recent';
  static const String dailyChart       = '$dashboardBaseUrl/expenses/daily';
  static const String spendingInsights = '$dashboardBaseUrl/spending/insights';

  // ── Authenticated headers — reads JWT from SharedPreferences ─────────────
  static Future<Map<String, String>> get authHeaders async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Public headers — for login / register (no token needed) ──────────────
  static Map<String, String> get publicHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}