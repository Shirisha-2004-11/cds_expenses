// ─────────────────────────────────────────────────────────────────────────────
// lib/Dashboard_path/Dashboard.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Monthly_analystics.dart';
import 'SpendingSummaryRow.dart';
import 'Greating_header.dart';
import 'ExpenseScreen.dart';
import 'Expenses_History.dart';
import 'InsightsCards.dart';
import 'profile_screen.dart';
import 'budget_overview_screen.dart';
import '../services/expense_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Consumer<ExpenseProvider>(
          builder: (context, provider, _) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _currentNavIndex == 0
                ? _buildHomeBody(provider)
                : const Center(child: SizedBox.shrink());
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeBody(ExpenseProvider p) {
    return RefreshIndicator(
      onRefresh: () => context.read<ExpenseProvider>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GreetingHeader(),
            const SizedBox(height: 12),
            MonthlyAnalyticsCard(monthlyTrend: p.monthlyTrend),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(child: SpendingSummaryRow(provider: p)),
            ),
            const SizedBox(height: 10),
            _buildInsightsCard(p),
            const SizedBox(height: 12),
            _buildRecentExpenses(p),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'travel':
        return Icons.directions_car;
      case 'supplies':
        return Icons.shopping_cart;
      case 'bills':
        return Icons.receipt_long;
      case 'entertainment':
        return Icons.movie;
      case 'medical':
        return Icons.local_pharmacy;
      case 'education':
        return Icons.school;
      case 'rent':
        return Icons.home;
      case 'petrol':
        return Icons.local_gas_station;
      case 'electricity':
        return Icons.electric_bolt;
      case 'home services':
        return Icons.home_repair_service;
      default:
        return Icons.category;
    }
  }

  Widget _buildInsightsCard(ExpenseProvider p) {
    final insights = p.insightItems;
    if (insights.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No insights yet — add expenses to see breakdown',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }
    final double total = insights.fold<double>(
      0.0,
      (s, e) => s + (e['amount'] as num).toDouble(),
    );
    if (total == 0) return const SizedBox.shrink();
    final now = DateTime.now();
    final monthName = const [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][now.month];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SpendingInsightsScreen(provider: p)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Insights',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '$monthName ${now.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(
                    painter: DonutChartPainter(
                      data: insights
                          .map((e) => (e['amount'] as num).toDouble())
                          .toList(),
                      colors: insights.map((e) => e['color'] as Color).toList(),
                      total: total,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: insights
                        .take(4)
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: (e['color'] as Color).withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    _iconForCategory(e['label'] as String),
                                    color: e['color'] as Color,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e['label'] as String,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  '₹ ${(e['amount'] as num).toInt()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BudgetOverviewScreen(provider: p),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View report',
                    style: TextStyle(color: Color(0xFF4A90D9), fontSize: 13),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Color(0xFF4A90D9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(ExpenseProvider p) {
    final recent = p.recentExpenses;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Expenses',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text(
                      'This month',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No expenses yet — tap + to add one',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            ...recent.map((e) => _buildExpenseItem(e)),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 220,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecentExpensesPage(provider: p),
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF2D7A6B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'See  all expense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Expense e) {
    // "Today" if entered today, otherwise plain date
    String dateLabel = '';
    try {
      final saved = DateTime.parse(e.savedAt);
      final now = DateTime.now();
      final isToday = saved.year == now.year &&
          saved.month == now.month &&
          saved.day == now.day;
      dateLabel = isToday
          ? 'Today'
          : '${saved.day}/${saved.month}/${saved.year}';
    } catch (_) {
      dateLabel = e.savedAt;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: e.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(e.icon, color: e.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.merchant,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '$dateLabel  •  ${e.category}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '-₹ ${e.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddExpensePage(
                  onExpenseAdded: (category, merchant, date, note, amount,
                      paymentMethod, savedAt) {
                    context.read<ExpenseProvider>().addExpense(
                          category: category,
                          merchant: merchant,
                          date: date,
                          note: note,
                          amount: amount,
                          paymentMethod: paymentMethod,
                          savedAt: savedAt,
                        );
                  },
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          } else {
            setState(() => _currentNavIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A1A2E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  BarChartPainter({required this.data, required this.labels});
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;
    final double chartHeight = size.height - 18;
    final double barWidth = size.width / (data.length * 1.8);
    final double spacing = size.width / data.length;
    final colors = [
      const Color(0xFF81C784),
      const Color(0xFF4FC3F7),
      const Color(0xFFFFB347),
      const Color(0xFFCE93D8),
      const Color(0xFF4FC3F7),
      const Color(0xFF81C784),
      const Color(0xFFFFB347),
      const Color(0xFF4FC3F7),
      const Color(0xFF81C784),
    ];
    for (int i = 0; i < data.length; i++) {
      final barH = (data[i] / maxVal) * chartHeight;
      final x = i * spacing + spacing / 2 - barWidth / 2;
      final y = chartHeight - barH;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barH),
          const Radius.circular(4),
        ),
        Paint()..color = colors[i % colors.length],
      );
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + barWidth / 2 - tp.width / 2, chartHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => true;
}

class DonutChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  final double total;
  DonutChartPainter({
    required this.data,
    required this.colors,
    required this.total,
  });
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;
    double startAngle = -3.14159 / 2;
    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i] / total) * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.05,
        false,
        Paint()
          ..color = colors[i]
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => true;
}