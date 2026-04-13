// ─────────────────────────────────────────────────────────────────────────────
// lib/services/dashboard_service.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class BudgetSummary {
  final double totalBudget;
  final double totalSpent;
  BudgetSummary({required this.totalBudget, required this.totalSpent});

  factory BudgetSummary.fromJson(Map<String, dynamic> j) => BudgetSummary(
    totalBudget: (j['totalBudget'] ?? j['total_budget'] ?? 0).toDouble(),
    totalSpent: (j['totalSpent'] ?? j['total_spent'] ?? 0).toDouble(),
  );

  factory BudgetSummary.mock() =>
      BudgetSummary(totalBudget: 50000, totalSpent: 32400);
}

class InsightItem {
  final String label;
  final int amount;
  final Color color;
  InsightItem({required this.label, required this.amount, required this.color});

  factory InsightItem.fromJson(Map<String, dynamic> j) => InsightItem(
    label: j['label'] ?? j['category'] ?? 'Other',
    amount: (j['amount'] ?? j['total'] ?? 0).toInt(),
    color: _colorFor(j['label'] ?? j['category'] ?? ''),
  );

  static Color _colorFor(String label) {
    switch (label.toLowerCase()) {
      case 'food':          return const Color(0xFFFF6B6B);
      case 'travel':        return const Color(0xFF4FC3F7);
      case 'supplies':      return const Color(0xFFA5D6A7);
      case 'bills':         return const Color(0xFFFFB347);
      case 'medical':       return const Color(0xFF81C784);
      case 'entertainment': return const Color(0xFFCE93D8);
      default:              return const Color(0xFFCE93D8);
    }
  }

  static List<InsightItem> mockList() => [
    InsightItem(label: 'Food',     amount: 12400, color: const Color(0xFFFF6B6B)),
    InsightItem(label: 'Travel',   amount: 8200,  color: const Color(0xFF4FC3F7)),
    InsightItem(label: 'Supplies', amount: 6800,  color: const Color(0xFFA5D6A7)),
    InsightItem(label: 'Bills',    amount: 5000,  color: const Color(0xFFFFB347)),
  ];
}

class ExpenseItem {
  final String   category;   // real category: Food, Travel, Bills, Medical...
  final String   merchant;   // vendor/store name: trifecta, ola, udipi...
  final String   date;       // bill/expense date from API
  final String   savedAt;  // date the entry was saved/entered
  final String   subtitle;
  final int      amount;
  final IconData icon;
  final Color    color;
  final bool     highlight;

  ExpenseItem({
    required this.category,
    required this.merchant,
    required this.date,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
    required this.highlight,
    this.savedAt = '',
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> j) {
    // categoryName / category = real type (Food, Travel, Bills...)
    // merchant / name / description = store name (trifecta, ola, udipi...)
    final cat   = (j['categoryName'] ?? j['category'] ?? 'Other').toString();
    final merch = (j['merchant'] ?? j['name'] ?? j['description'] ?? '').toString();
    return ExpenseItem(
      category:  cat,
      merchant:  merch,
      date:      (j['expenseDate'] ?? j['date'] ?? '').toString(),
      savedAt: (j['savedAt'] ?? j['createdAt'] ?? j['enteredAt'] ?? '').toString(),
      subtitle:  (j['description'] ?? j['subtitle'] ?? '').toString(),
      amount:    (j['amount'] ?? 0).toInt(),
      icon:      _iconFor(cat),
      color:     _colorFor(cat),
      highlight: j['highlight'] ?? false,
    );
  }

  // Icon driven by real category — not merchant name
  static IconData _iconFor(String cat) {
    switch (cat.toLowerCase()) {
      case 'food':          return Icons.fastfood;
      case 'travel':        return Icons.directions_car;
      case 'bills':         return Icons.receipt_long;
      case 'medical':       return Icons.local_pharmacy;
      case 'entertainment': return Icons.movie;
      case 'supplies':      return Icons.shopping_bag;
      case 'education':     return Icons.school;
      default:              return Icons.shopping_bag;
    }
  }

  // Color driven by real category — not merchant name
  static Color _colorFor(String cat) {
    switch (cat.toLowerCase()) {
      case 'food':          return const Color(0xFFFF6B6B);
      case 'travel':        return const Color(0xFF4FC3F7);
      case 'bills':         return const Color(0xFFFFB347);
      case 'medical':       return const Color(0xFF81C784);
      case 'entertainment': return const Color(0xFFCE93D8);
      case 'supplies':      return const Color(0xFFA5D6A7);
      case 'education':     return const Color(0xFF4DB6AC);
      default:              return const Color(0xFFA5D6A7);
    }
  }

  static List<ExpenseItem> mockList() => [
    ExpenseItem(
      category:  'Food',
      merchant:  'Swiggy',
      date:      'Today',
      subtitle:  'Food delivery',
      amount:    450,
      icon:      Icons.fastfood,
      color:     const Color(0xFFFF6B6B),
      highlight: true,
    ),
    ExpenseItem(
      category:  'Travel',
      merchant:  'Uber',
      date:      'Yesterday',
      subtitle:  'Cab ride',
      amount:    220,
      icon:      Icons.directions_car,
      color:     const Color(0xFF4FC3F7),
      highlight: false,
    ),
  ];
}

class ChartData {
  final List<double> values;
  final List<String> days;
  ChartData({required this.values, required this.days});

  factory ChartData.fromJson(dynamic json) {
    List<dynamic> list = [];
    if (json is List) {
      list = json;
    } else if (json is Map && json.containsKey('data')) {
      list = json['data'] as List<dynamic>;
    }
    final values = list
        .map((e) => (e['amount'] ?? e['value'] ?? e['total'] ?? 0).toDouble())
        .toList()
        .cast<double>();
    final days = list
        .map((e) => (e['month'] ?? e['day'] ?? e['label'] ?? '').toString())
        .toList()
        .cast<String>();
    return ChartData(values: values, days: days);
  }

  factory ChartData.mock() => ChartData(
    values: [3200, 4100, 2800, 5200, 3800, 4600, 3100, 5800, 4200],
    days:   ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue'],
  );
}

class DashboardData {
  final BudgetSummary      budget;
  final List<InsightItem>  insights;
  final List<ExpenseItem>  recentExpenses;
  final ChartData          chartData;

  DashboardData({
    required this.budget,
    required this.insights,
    required this.recentExpenses,
    required this.chartData,
  });

  factory DashboardData.mock() => DashboardData(
    budget:         BudgetSummary.mock(),
    insights:       InsightItem.mockList(),
    recentExpenses: ExpenseItem.mockList(),
    chartData:      ChartData.mock(),
  );
}

// ─── Service ──────────────────────────────────────────────────────────────────

class DashboardService {
  static Future<DashboardData> fetchAll() async {
    final headers = await ApiConfig.authHeaders;

    final results = await Future.wait([
      _getSafe(ApiConfig.budgetSummary,  headers),
      _getSafe(ApiConfig.insights,       headers),
      _getSafe(ApiConfig.recentExpenses, headers),
      _getSafe(ApiConfig.dailyChart,     headers),
    ]);

    // Budget
    BudgetSummary budget;
    try {
      budget = BudgetSummary.fromJson(results[0] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Budget parse error: $e');
      budget = BudgetSummary.mock();
    }

    // Insights
    List<InsightItem> insights;
    try {
      final raw = results[1];
      final list = raw is List
          ? raw
          : (raw as Map?)?['data'] as List? ?? [];
      insights = list.map((e) => InsightItem.fromJson(e as Map<String, dynamic>)).toList();
      debugPrint('Insights loaded: ${insights.length} items');
    } catch (e) {
      debugPrint('Insights parse error: $e');
      insights = InsightItem.mockList();
    }

    // Recent expenses
    List<ExpenseItem> recent;
    try {
      final raw = results[2];
      final list = raw is List
          ? raw
          : (raw as Map?)?['data'] as List? ?? [];
      recent = list.map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>)).toList();
      debugPrint('Recent expenses loaded: ${recent.length} items');
      // Debug: print each expense so we can see category vs merchant
      for (final r in recent) {
        debugPrint('  expense → category: "${r.category}"  merchant: "${r.merchant}"');
      }
    } catch (e) {
      debugPrint('Recent expenses parse error: $e');
      recent = ExpenseItem.mockList();
    }

    // Chart
    ChartData chart;
    try {
      chart = ChartData.fromJson(results[3]);
    } catch (e) {
      debugPrint('Chart parse error: $e');
      chart = ChartData.mock();
    }

    return DashboardData(
      budget:         budget,
      insights:       insights,
      recentExpenses: recent,
      chartData:      chart,
    );
  }

  static Future<dynamic> _getSafe(String url, Map<String, String> headers) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      debugPrint('GET $url failed: ${response.statusCode} — ${response.body}');
      return null;
    } catch (e) {
      debugPrint('GET $url error: $e');
      return null;
    }
  }
}