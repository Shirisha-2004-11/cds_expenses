import 'package:flutter/material.dart';
import 'Monthly_analystics.dart';
import 'Stats_row.dart';
import 'Greating_header.dart';
import 'monthly_progress.dart';
import 'ExpenseScreen.dart';
import 'Expenses_History.dart';
// ── Centralised theme tokens (colors, text styles, widgets) ──────────────────
// ignore: unused_import
import '../theme/dashboard_colors.dart';
// ignore: unused_import
import '../theme/dashboard_text_styles.dart';
// ignore: unused_import
import '../widgets/common/dashboard_card.dart';
// ignore: unused_import
import '../widgets/common/dashboard_icon_box.dart';

// Removed: import '../unused_code/expence_using_API.dart'; ← file doesn't exist

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;
  String selectedPeriod = 'This year';

  final double totalBudget = 20000;
  final double totalSpent = 14480;

  final List<Map<String, dynamic>> insights = [
    {'label': 'Food', 'amount': 4050, 'color': Color(0xFFFFB347)},
    {'label': 'Travel', 'amount': 2540, 'color': Color(0xFF4FC3F7)},
    {'label': 'Supplies', 'amount': 4100, 'color': Color(0xFFAED581)},
    {'label': 'Bills', 'amount': 3790, 'color': Color(0xFFCE93D8)},
  ];

  final List<Map<String, dynamic>> recentExpenses = [
    {
      'category': 'Food',
      'date': 'April 23',
      'subtitle': 'Lunch',
      'amount': -450,
      'icon': Icons.fastfood,
      'color': Color(0xFFFFB347),
      'highlight': false,
    },
    {
      'category': 'Travel',
      'date': 'April 23',
      'subtitle': 'Taxi fare',
      'amount': -280,
      'icon': Icons.directions_car,
      'color': Color(0xFF4FC3F7),
      'highlight': false,
    },
    {
      'category': 'Health',
      'date': 'April 21',
      'subtitle': 'Pharmacy',
      'amount': -400,
      'icon': Icons.local_pharmacy,
      'color': Color(0xFF81C784),
      'highlight': true,
    },
    {
      'category': 'Bills',
      'date': 'April 21',
      'subtitle': 'Electricity bills',
      'amount': -1200,
      'icon': Icons.receipt_long,
      'color': Color(0xFFCE93D8),
      'highlight': false,
    },
  ];

  final List<double> dailyData = [30, 60, 80, 45, 90, 70, 55, 85, 65];
  final List<String> days = [
    '21', '22', '23', '24', '25', '26', '27', '28', '29',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: _currentNavIndex == 0
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
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpensePage(),
                ),
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
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
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
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Budget',
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GreetingHeader(),
          const SizedBox(height: 12),
          BudgetProgressCard(totalBudget: totalBudget, totalSpent: totalSpent),
          const SizedBox(height: 12),
          const MonthlyAnalyticsCard(),
          const SizedBox(height: 12),
          const StatsRow(),
          const SizedBox(height: 10),
          _buildInsightsCard(),
          const SizedBox(height: 12),
          _buildDailyBarChart(),
          const SizedBox(height: 12),
          _buildRecentExpenses(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    final total = insights.fold<double>(
      0,
      (sum, e) => sum + (e['amount'] as int),
    );
    return Container(
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
              Text(
                'Insights',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                'March 2020',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
                        .map((e) => (e['amount'] as int).toDouble())
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
                      .map(
                        (e) => Padding(
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
                                child: Text(
                                  e['label'] as String,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                '₹ ${e['amount']}',
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
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'View report',
                style: TextStyle(color: Color(0xFF4A90D9), fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBarChart() {
    return Container(
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
      child: SizedBox(
        height: 100,
        child: CustomPaint(
          size: const Size(double.infinity, 100),
          painter: BarChartPainter(data: dailyData, labels: days),
        ),
      ),
    );
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
                      'Last 30 days',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentExpenses.map((expense) => _buildExpenseItem(expense)),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecentExpensesPage(),
                  ),
                );
              },
              child: const Text(
                'See All Expenses →',
                style: TextStyle(
                  color: Color(0xFF4A90D9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
            child: Icon(
              expense['icon'] as IconData,
              color: expense['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense['category'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '${expense['date']}  •  ${expense['subtitle']}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
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

  Widget _buildPlaceholderPage(int index) {
    final titles = ['', 'Stats', 'Add Expense', 'Budget', 'Profile'];
    final icons = [
      Icons.home,
      Icons.bar_chart,
      Icons.add_circle,
      Icons.account_balance_wallet,
      Icons.person,
    ];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icons[index], size: 64, color: const Color(0xFF1A1A2E)),
          const SizedBox(height: 16),
          Text(
            titles[index],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Not yet decided...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painters ────────────────────────────────────────────────────────────

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  BarChartPainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double chartHeight = size.height - 18;
    final double barWidth = size.width / (data.length * 1.8);
    final double spacing = size.width / data.length;
    final List<Color> barColors = [
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
      final double barH = (data[i] / maxVal) * chartHeight;
      final double x = i * spacing + spacing / 2 - barWidth / 2;
      final double y = chartHeight - barH;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barH),
          const Radius.circular(4),
        ),
        Paint()..color = barColors[i % barColors.length],
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}