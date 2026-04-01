// import 'package:flutter/material.dart';
// import 'screens/auth/welcome_screen.dart';
// import 'Dashboard_path/Dashboard.dart';
// import 'theme/app_theme.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const CDSExpensesApp());
// }

// class CDSExpensesApp extends StatelessWidget {
//   const CDSExpensesApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'CDS Expenses',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       home: const WelcomeScreen(),
//       routes: {
//         '/dashboard': (context) => const DashboardScreen(),
//       },
//     );
//   }
// // }
// import 'package:cds_expenses/Dashboard_path/InsightsCards/SpendingGaugeCard.dart';
// import 'package:cds_expenses/screens/auth/welcome_screen.dart';
// import 'package:flutter/material.dart';
// import 'Dashboard_path/Dashboard.dart';
// import 'theme/app_theme.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const CDSExpensesApp());
// }

// class CDSExpensesApp extends StatelessWidget {
//   const CDSExpensesApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'CDS Expenses',
//       debugShowCheckedModeBanner: false,

//       // ✅ Theme
//       theme: AppTheme.lightTheme,

//       // ✅ Initial Screen (IMPORTANT FIX)
//       home: const _SpendingGaugeCard(),

//       // ✅ Routes (for future navigation)
//       routes: {'/dashboard': (context) => const _SpendingGaugeCard()},
//     );
//   }
// }
import 'package:cds_expenses/screens/auth/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:cds_expenses/Dashboard_path/Dashboard.dart';
import 'package:cds_expenses/theme/app_theme.dart';
import 'package:cds_expenses/Dashboard_path/InsightsCards.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CDSExpensesApp());
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
        '/insights': (context) => const SpendingInsightsScreen(),
      },
    );
  }
}
