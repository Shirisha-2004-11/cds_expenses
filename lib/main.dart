// ─────────────────────────────────────────────────────────────────────────────
// lib/main.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cds_expenses/screens/auth/welcome_screen.dart';
import 'package:cds_expenses/Dashboard_path/Dashboard.dart';
import 'package:cds_expenses/theme/app_theme.dart';
import 'package:cds_expenses/services/auth_state.dart';
import 'package:cds_expenses/services/expense_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Re-hydrate in-memory token from SharedPreferences on cold start.
  final prefs      = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('auth_token');
  final savedName  = prefs.getString('user_name');
  final savedEmail = prefs.getString('user_email');
  final savedId    = prefs.getString('user_id');

  if (savedToken != null && savedToken.isNotEmpty) {
    AuthState.setToken(
      savedToken,
      userName:  savedName,
      userEmail: savedEmail,
      userId:    savedId,
    );

    // ── Console log restored credentials on app start ──
    debugPrint('╔══════════════════════════════════════════');
    debugPrint('║  CREDENTIALS RESTORED FROM STORAGE');
    debugPrint('╠══════════════════════════════════════════');
    debugPrint('║  user_name  : $savedName');
    debugPrint('║  user_email : $savedEmail');
    debugPrint('║  auth_token : $savedToken');
    debugPrint('╚══════════════════════════════════════════');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: const CDSExpensesApp(),
    ),
  );
}

class CDSExpensesApp extends StatelessWidget {
  const CDSExpensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // If a token was restored from SharedPreferences, go straight to dashboard.
    // Otherwise show the welcome / sign-in screen.
    final Widget home = AuthState.isLoggedIn
        ? const DashboardScreen()
        : const WelcomeScreen();

    return MaterialApp(
      title: 'CDS Expenses',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: home,
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/welcome':   (context) => const WelcomeScreen(),
      },
    );
  }
}
