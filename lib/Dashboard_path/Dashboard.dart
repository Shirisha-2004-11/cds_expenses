// ─────────────────────────────────────────────────────────────────────────────
// lib/screens/dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'Monthly_analystics.dart';
import 'SpendingSummaryRow.dart';
import 'Greating_header.dart';
import 'monthly_progress.dart';
import 'ExpenseScreen.dart';
import 'Expenses_History.dart';
import 'InsightsCards.dart';
import 'profile_screen.dart';                        // ← added
import '../services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int    _currentNavIndex = 0;
  String selectedPeriod   = 'This year';

  bool          _loading = true;
  DashboardData _data    = DashboardData.mock();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final result = await DashboardService.fetchAll();
    if (mounted) {
      setState(() {
        _data    = result;
        _loading = false;
      });
    }
  }

  double get totalBudget => _data.budget.totalBudget;
  double get totalSpent  => _data.budget.totalSpent;

  List<Map<String, dynamic>> get insights => _data.insights
      .map((e) => {'label': e.label, 'amount': e.amount, 'color': e.color})
      .toList();

  List<Map<String, dynamic>> get recentExpenses => _data.recentExpenses
      .map((e) => {
            'category' : e.category,
            'date'     : e.date,
            'subtitle' : e.subtitle,
            'amount'   : e.amount,
            'icon'     : e.icon,
            'color'    : e.color,
            'highlight': e.highlight,
          })
      .toList();

  List<double> get dailyData => _data.chartData.values;
  List<String> get days      => _data.chartData.days;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _currentNavIndex == 0
                ? _buildHomeBody()
                : _buildPlaceholderPage(_currentNavIndex),
      ),
      bottomNavigationBar: Container(
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
              // Add expense page — push without changing nav index
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpensePage()),
              );
            } else if (index == 2) {
              // ── Navigate to ProfileScreen ──────────────────────────────
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
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
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
      ),
    );
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GreetingHeader(),
            const SizedBox(height: 12),
            BudgetProgressCard(totalBudget: totalBudget, totalSpent: totalSpent),
            const SizedBox(height: 12),
            const MonthlyAnalyticsCard(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(child: SpendingSummaryRow()),
            ),
            const SizedBox(height: 10),
            _buildInsightsCard(),
            const SizedBox(height: 12),
            _buildRecentExpenses(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    final total = insights.fold<double>(
        0, (sum, e) => sum + (e['amount'] as int));
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SpendingInsightsScreen()),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Insights',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E))),
              Text('March 2020',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                        .map((e) => (e['amount'] as int).toDouble())
                        .toList(),
                    colors:
                        insights.map((e) => e['color'] as Color).toList(),
                    total: total,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: insights
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: (e['color'] as Color)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    e['label'] == 'Food'
                                        ? Icons.fastfood
                                        : e['label'] == 'Travel'
                                            ? Icons.directions_car
                                            : e['label'] == 'Supplies'
                                                ? Icons.shopping_bag
                                                : Icons.receipt_long,
                                    color: e['color'] as Color,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(e['label'] as String,
                                      style: const TextStyle(fontSize: 13)),
                                ),
                                Text('₹ ${e['amount']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('View report',
                  style: TextStyle(color: Color(0xFF4A90D9), fontSize: 13)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF4A90D9)),
            ],
          ),
        ],
      ),
    ),  // closes Container
    ); // closes GestureDetector
  }

  Widget _buildRecentExpenses() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Expenses',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1A1A2E))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('Last 30 days',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Icon(Icons.arrow_drop_down,
                        size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentExpenses.map((e) => _buildExpenseItem(e)),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RecentExpensesPage()),
              ),
              child: const Text('See All Expenses →',
                  style: TextStyle(
                      color: Color(0xFF4A90D9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Map<String, dynamic> expense) {
    final bool highlight = expense['highlight'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFFF9C4) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: const Color(0xFFFFD54F), width: 1.5)
            : null,
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
              color: (expense['color'] as Color).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(expense['icon'] as IconData,
                color: expense['color'] as Color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense['category'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E))),
                Text(
                    '${expense['date']}  •  ${expense['subtitle']}',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            '-₹ ${(expense['amount'] as int).abs()}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: highlight
                  ? const Color(0xFFF57C00)
                  : const Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }

  // This is now only used for index 0 fallback — index 2 navigates to ProfileScreen
  Widget _buildPlaceholderPage(int index) {
    const titles = ['', '', 'Profile'];
    const icons  = [Icons.home, Icons.add_circle, Icons.person];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icons[index], size: 64, color: const Color(0xFF1A1A2E)),
          const SizedBox(height: 16),
          Text(titles[index],
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          const Text('Not yet decided...',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ── Custom Painters ───────────────────────────────────────────────────────────

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  BarChartPainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double maxVal      = data.reduce((a, b) => a > b ? a : b);
    final double chartHeight = size.height - 18;
    final double barWidth    = size.width / (data.length * 1.8);
    final double spacing     = size.width / data.length;
    final colors = [
      const Color(0xFF81C784), const Color(0xFF4FC3F7),
      const Color(0xFFFFB347), const Color(0xFFCE93D8),
      const Color(0xFF4FC3F7), const Color(0xFF81C784),
      const Color(0xFFFFB347), const Color(0xFF4FC3F7),
      const Color(0xFF81C784),
    ];
    for (int i = 0; i < data.length; i++) {
      final barH = (data[i] / maxVal) * chartHeight;
      final x    = i * spacing + spacing / 2 - barWidth / 2;
      final y    = chartHeight - barH;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, barWidth, barH), const Radius.circular(4)),
        Paint()..color = colors[i % colors.length],
      );
      final tp = TextPainter(
        text: TextSpan(
            text: labels[i],
            style: const TextStyle(fontSize: 9, color: Colors.grey)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(x + barWidth / 2 - tp.width / 2, chartHeight + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => true;
}

class DonutChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color>  colors;
  final double       total;
  DonutChartPainter(
      {required this.data, required this.colors, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center      = Offset(size.width / 2, size.height / 2);
    final radius      = size.width / 2;
    const strokeWidth = 14.0;
    double startAngle = -3.14159 / 2;
    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i] / total) * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(
            center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.05,
        false,
        Paint()
          ..color       = colors[i]
          ..strokeWidth = strokeWidth
          ..style       = PaintingStyle.stroke
          ..strokeCap   = StrokeCap.round,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => true;
}