// ─────────────────────────────────────────────────────────────────────────────
// lib/services/expense_provider.dart
//
// Central reactive state for the entire dashboard.
// Every screen listens to this — adding one expense updates ALL pages.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'dashboard_service.dart';

// ─── A single expense entry (normalised from API or added locally) ────────────

class Expense {
  final String id;
  final String category;
  final String merchant;
  final String date; // ISO-8601 string  e.g. "2025-04-07"
  final String note;
  final double amount;
  final String paymentMethod;

  const Expense({
    required this.id,
    required this.category,
    required this.merchant,
    required this.date,
    required this.note,
    required this.amount,
    required this.paymentMethod,
  });

  /// Build from the API map returned by /expenses endpoint
  factory Expense.fromJson(Map<String, dynamic> j) {
    final cat = (j['category'] ?? j['categoryName'] ?? 'Other').toString();
    final merch = (j['merchant'] ?? j['description'] ?? cat).toString();
    final date = (j['expenseDate'] ?? j['date'] ?? '').toString();
    final amt = (j['amount'] ?? 0).toDouble();
    final pay = (j['paymentMethod'] ?? 'UPI').toString();
    final note = (j['note'] ?? j['subtitle'] ?? '').toString();
    final id = (j['id'] ?? j['expenseId'] ?? UniqueKey().toString()).toString();

    return Expense(
      id: id,
      category: cat,
      merchant: merch,
      date: date,
      note: note,
      amount: amt,
      paymentMethod: pay,
    );
  }

  IconData get icon {
    switch (category.toLowerCase()) {
      case 'food':          return Icons.fastfood;
      case 'travel':        return Icons.directions_car;
      case 'supplies':      return Icons.shopping_cart;
      case 'bills':         return Icons.receipt_long;
      case 'entertainment': return Icons.movie;
      case 'medical':       return Icons.local_pharmacy;
      case 'education':     return Icons.school;
      case 'rent':          return Icons.home;
      case 'petrol':        return Icons.local_gas_station;
      case 'electricity':   return Icons.electric_bolt;
      case 'home services': return Icons.home_repair_service;
      default:              return Icons.category;
    }
  }

  Color get color {
    switch (category.toLowerCase()) {
      case 'food':          return const Color(0xFFFF6B6B);
      case 'travel':        return const Color(0xFF4FC3F7);
      case 'supplies':      return const Color(0xFFEFA169);
      case 'bills':         return const Color(0xFFFFB347);
      case 'entertainment': return const Color(0xFFCE93D8);
      case 'medical':       return const Color(0xFF81C784);
      case 'education':     return const Color(0xFF4DB6AC);
      case 'rent':          return const Color(0xFFFFD54F);
      case 'petrol':        return const Color(0xFFFF8A65);
      case 'electricity':   return const Color(0xFFFDD835);
      case 'home services': return const Color(0xFF90CAF9);
      default:              return const Color(0xFF90A4AE);
    }
  }

  DateTime? get parsedDate {
    try {
      return DateTime.parse(date);
    } catch (_) {
      return null;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

class ExpenseProvider extends ChangeNotifier {
  // ── Raw state ──────────────────────────────────────────────────────────────
  List<Expense> _expenses = [];
  double _totalBudget = 0;
  bool _loading = true;
  String? _error;

  // ── Public getters ─────────────────────────────────────────────────────────
  bool get loading => _loading;
  String? get error => _error;
  double get totalBudget => _totalBudget;

  List<Expense> get allExpenses => List.unmodifiable(_expenses);

  // ── This month's expenses ──────────────────────────────────────────────────
  List<Expense> get thisMonthExpenses {
    final now = DateTime.now();
    return _expenses.where((e) {
      final d = e.parsedDate;
      return d != null && d.year == now.year && d.month == now.month;
    }).toList();
  }

  double get totalSpentThisMonth =>
      thisMonthExpenses.fold(0.0, (s, e) => s + e.amount);

  // ── Category breakdown (this month) ───────────────────────────────────────
  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (final e in thisMonthExpenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  /// Sorted by amount descending
  List<MapEntry<String, double>> get sortedCategories {
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  MapEntry<String, double>? get highestCategory =>
      sortedCategories.isEmpty ? null : sortedCategories.first;

  // ── Daily average (this month) ─────────────────────────────────────────────
  double get dailyAverage {
    final today = DateTime.now();
    final daysElapsed = today.day; // days elapsed in current month
    if (daysElapsed == 0) return 0;
    return totalSpentThisMonth / daysElapsed;
  }

  // ── Daily spending map {day-of-month → total} for chart ───────────────────
  Map<int, double> get dailySpendingMap {
    final map = <int, double>{};
    for (final e in thisMonthExpenses) {
      final d = e.parsedDate;
      if (d != null) {
        map[d.day] = (map[d.day] ?? 0) + e.amount;
      }
    }
    return map;
  }

  /// Returns last N days of spend as (label, value) pairs for bar chart
  List<Map<String, dynamic>> get last10DaysChart {
    final today = DateTime.now();
    return List.generate(10, (i) {
      final day = today.subtract(Duration(days: 9 - i));
      final key = day.day;
      final val = dailySpendingMap[key] ?? 0.0;
      final lbl = '${key}';
      return {'label': lbl, 'value': val, 'date': day};
    });
  }

  /// Monthly trend data (by month) for MonthlyAnalyticsCard
  /// Returns current + previous 4 months
  List<Map<String, dynamic>> get monthlyTrend {
    final now = DateTime.now();
    return List.generate(5, (i) {
      final monthOffset = 4 - i;
      final target = DateTime(now.year, now.month - monthOffset, 1);
      final total = _expenses
          .where((e) {
            final d = e.parsedDate;
            return d != null &&
                d.year == target.year &&
                d.month == target.month;
          })
          .fold(0.0, (s, e) => s + e.amount);

      final shortNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final longNames = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC',
      ];

      return {
        'month': longNames[target.month - 1],
        'shortMonth': shortNames[target.month - 1],
        'amount': total,
        'year': target.year,
        'monthNum': target.month,
      };
    });
  }

  // ── Weekly total ───────────────────────────────────────────────────────────
  double get thisWeekTotal {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return _expenses
        .where((e) {
          final d = e.parsedDate;
          return d != null &&
              !d.isBefore(DateTime(start.year, start.month, start.day));
        })
        .fold(0.0, (s, e) => s + e.amount);
  }

  // ── Category breakdown (ALL expenses) ─────────────────────────────────────
  Map<String, double> get categoryTotalsAll {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  /// Sorted by amount descending (all expenses)
  List<MapEntry<String, double>> get sortedCategoriesAll {
    final entries = categoryTotalsAll.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  // ── Insight items (for donut chart) — uses ALL expenses ───────────────────
  List<Map<String, dynamic>> get insightItems {
    return sortedCategoriesAll.map((entry) {
      final dummy = Expense(
        id: '',
        category: entry.key,
        merchant: '',
        date: '',
        note: '',
        amount: 0,
        paymentMethod: '',
      );
      return {
        'label': entry.key,
        'amount': entry.value.toInt(),
        'color': dummy.color,
      };
    }).toList();
  }

  // ── Recent 10 expenses ────────────────────────────────────────────────────
  List<Expense> get recentExpenses {
    final sorted = List<Expense>.from(_expenses)
      ..sort((a, b) {
        final da = a.parsedDate ?? DateTime(2000);
        final db = b.parsedDate ?? DateTime(2000);
        return db.compareTo(da);
      });
    return sorted.take(10).toList();
  }

  // ── Load from API ──────────────────────────────────────────────────────────
  Future<void> loadAll() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await DashboardService.fetchAll();

      // Convert service models → unified Expense list
      _expenses = data.recentExpenses
          .map(
            (e) => Expense(
              id: UniqueKey().toString(),
              category: e.category,
              merchant: e.category,
              date: _todayIso(),
              note: e.subtitle,
              amount: e.amount.toDouble(),
              paymentMethod: 'UPI',
            ),
          )
          .toList();

      _totalBudget = data.budget.totalBudget;
    } catch (e) {
      _error = e.toString();
      debugPrint('ExpenseProvider.loadAll error: $e');
    }

    _loading = false;
    notifyListeners();
  }

  // ── Called immediately after user adds a new expense ─────────────────────
  /// Optimistically insert the new expense so all pages update instantly.
  /// The actual HTTP POST is already done by ExpenseScreen.
  void addExpense({
    required String category,
    required String merchant,
    required String date,
    required String note,
    required double amount,
    required String paymentMethod,
  }) {
    _expenses.insert(
      0,
      Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        merchant: merchant,
        date: date.isNotEmpty ? date : _todayIso(),
        note: note,
        amount: amount,
        paymentMethod: paymentMethod,
      ),
    );
    notifyListeners();
  }

  /// Reload fresh data from the server (pull-to-refresh)
  Future<void> refresh() => loadAll();

  static String _todayIso() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
