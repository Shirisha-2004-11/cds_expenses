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
// }
import 'package:cds_expenses/screens/auth/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'Dashboard_path/Dashboard.dart';
import 'theme/app_theme.dart';

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

      // ✅ Theme
      theme: AppTheme.lightTheme,

      // ✅ Initial Screen (IMPORTANT FIX)
      home: const WelcomeScreen(),

      // ✅ Routes (for future navigation)
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}