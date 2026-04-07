// ─────────────────────────────────────────────────────────────────────────────
// lib/main.dart  (UPDATED — wires up ExpenseProvider)
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
  if (savedToken != null && savedToken.isNotEmpty) {
    AuthState.setToken(savedToken, userName: savedName);
  }

  runApp(
    // ── Wrap the whole app so every screen can access ExpenseProvider ──
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
    return MaterialApp(
      title: 'CDS Expenses',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
