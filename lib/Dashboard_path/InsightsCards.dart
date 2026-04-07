// ─────────────────────────────────────────────────────────────────────────────
// lib/Dashboard_path/InsightsCards.dart  (UPDATED — fully dynamic)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/expense_provider.dart';

// ─── Spending Insights Screen ─────────────────────────────────────────────────

class SpendingInsightsScreen extends StatelessWidget {
  final ExpenseProvider provider;

  const SpendingInsightsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5A5A5A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Spending insights',
          style: TextStyle(color: Color(0xFF5A5A5A), fontWeight: FontWeight.w600, fontSize: 20, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _TopCard(provider: provider),
            const SizedBox(height: 12),
            _BreakdownCard(provider: provider),
            const SizedBox(height: 16),
            _WeeklySummary(provider: provider),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Top Card ──────────────────────────────────────────────────────────────────

class _TopCard extends StatefulWidget {
  final ExpenseProvider provider;
  const _TopCard({required this.provider});
  @override
  State<_TopCard> createState() => _TopCardState();
}

class _TopCardState extends State<_TopCard> {
  int _activeIndex = 9; // most recent day

  List<Map<String, dynamic>> get _chartData => widget.provider.last10DaysChart;

  List<String>  get _days    => _chartData.map((e) => e['label'].toString()).toList();
  List<double>  get _amounts => _chartData.map((e) => (e['value'] as num).toDouble()).toList();

  List<double> get _heights {
    final maxVal = _amounts.isEmpty ? 1.0 : _amounts.reduce(math.max);
    return _amounts.map((a) => maxVal > 0 ? a / maxVal : 0.0).toList();
  }

  List<String> get _dates => _chartData.map((e) {
    final d = e['date'] as DateTime;
    final weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${d.day} ${_monthShort(d.month)} (${weekdays[d.weekday]})';
  }).toList();

  static String _monthShort(int m) => const ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];

  @override
  Widget build(BuildContext context) {
    final days    = _days;
    final amounts = _amounts;
    final heights = _heights;
    final dates   = _dates;
    final idx     = _activeIndex.clamp(0, amounts.isEmpty ? 0 : amounts.length - 1);
    final selAmt  = amounts.isEmpty ? 0.0 : amounts[idx];
    final selDate = dates.isEmpty ? '' : dates[idx];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT: gauge
                Container(
                  width: 150,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF1F5),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(13)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 150, height: 85,
                          child: CustomPaint(painter: _GaugePainter()),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          selAmt > 0 ? '₹ ${selAmt.toStringAsFixed(0)}' : '₹ 0',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Poppins', color: Color(0xFF1E1E1E)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          selAmt > 0 ? 'spent on $selDate' : 'no expenses',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF8E8E8E), fontSize: 11, fontFamily: 'Poppins'),
                        ),
                      ),
                    ],
                  ),
                ),
                // RIGHT: bar chart
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Daily spending', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins', color: Color(0xFF5A5A5A))),
                        const SizedBox(height: 4),
                        Text(
                          'Avg ₹ ${widget.provider.dailyAverage.toStringAsFixed(0)}/day this month',
                          style: const TextStyle(color: Color(0xFF8E8E8E), fontSize: 11, fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: amounts.isEmpty
                              ? const Center(child: Text('No data', style: TextStyle(color: Colors.grey, fontSize: 12)))
                              : _MiniBarChart(
                                  days:        days,
                                  heights:     heights,
                                  amounts:     amounts,
                                  activeIndex: idx,
                                  onTap:       (i) => setState(() => _activeIndex = i),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Bar Chart ────────────────────────────────────────────────────────────

class _MiniBarChart extends StatelessWidget {
  final List<String>  days;
  final List<double>  heights;
  final List<double>  amounts;
  final int           activeIndex;
  final ValueChanged<int> onTap;

  const _MiniBarChart({
    required this.days, required this.heights, required this.amounts,
    required this.activeIndex, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(days.length, (i) {
        final isActive = i == activeIndex;
        final barH     = math.max(heights[i] * 55.0, amounts[i] > 0 ? 6.0 : 2.0);
        return GestureDetector(
          onTap: () => onTap(i),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 16,
                height: barH,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF4D8BC6) : const Color(0xFFCBD8E9),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 3),
              Text(days[i], style: TextStyle(fontSize: 8.5, color: isActive ? const Color(0xFF4D8BC6) : const Color(0xFFAAAAAA), fontFamily: 'Poppins')),
            ],
          ),
        );
      }),
    );
  }
}

// ── Breakdown Card ────────────────────────────────────────────────────────────

class _BreakdownCard extends StatelessWidget {
  final ExpenseProvider provider;
  const _BreakdownCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    // Get today's expenses
    final today   = DateTime.now();
    final todayEx = provider.allExpenses.where((e) {
      final d = e.parsedDate;
      return d != null && d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();

    // Category totals for today
    final catMap = <String, double>{};
    for (final e in todayEx) catMap[e.category] = (catMap[e.category] ?? 0) + e.amount;
    final sorted = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Average daily spend for comparison
    final avgDay = provider.dailyAverage;
    final todayTotal = todayEx.fold(0.0, (s, e) => s + e.amount);
    final biggestCat = sorted.isNotEmpty ? sorted.first : null;

    final dateLabel = '${today.day} ${_monthName(today.month)} breakdown';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabel,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Poppins', color: Color(0xFF5A5A5A)),
          ),
          const SizedBox(height: 16),

          if (sorted.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text('No expenses today', style: TextStyle(color: Colors.grey, fontSize: 13))),
            )
          else ...[
            // Category grid
            ...List.generate((sorted.length / 2).ceil(), (row) {
              final left  = sorted[row * 2];
              final right = row * 2 + 1 < sorted.length ? sorted[row * 2 + 1] : null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(child: _CatTile(label: left.key, amount: '₹ ${left.value.toStringAsFixed(0)}')),
                    const SizedBox(width: 12),
                    Expanded(child: right != null ? _CatTile(label: right.key, amount: '₹ ${right.value.toStringAsFixed(0)}') : const SizedBox.shrink()),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFDDDDDD)),
          const SizedBox(height: 12),

          const Text('Compared to your average day', style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
          const SizedBox(height: 8),

          if (avgDay > 0 && todayTotal > 0) ...[
            _CmpRow(amount: '₹ ${(todayTotal - avgDay).abs().toStringAsFixed(0)}', label: todayTotal > avgDay ? 'more than avg day' : 'less than avg day'),
          ] else
            const Text('  Not enough data yet', style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12)),

          if (biggestCat != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.8, color: Color(0xFFDDDDDD)),
            const SizedBox(height: 12),
            Text('Biggest contributor: ${biggestCat.key}', style: const TextStyle(color: Color(0xFF8E8E8E), fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
            const SizedBox(height: 3),
            Text(
              '${biggestCat.key} is ${((biggestCat.value / todayTotal) * 100).toStringAsFixed(0)}% of today\'s spend',
              style: const TextStyle(color: Color(0xFF8E8E8E), fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w400),
            ),
          ],
        ],
      ),
    );
  }

  static String _monthName(int m) => const ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
}

// ── Category Tile ─────────────────────────────────────────────────────────────

class _CatTile extends StatelessWidget {
  final String label;
  final String amount;
  const _CatTile({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(category: label),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label  $amount',
            style: const TextStyle(color: Color(0xFF5F5F5F), fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final String category;
  const _IconBox({required this.category});

  @override
  Widget build(BuildContext context) {
    final data = _data();
    return Container(
      width: 36, height: 30,
      decoration: BoxDecoration(color: data['bg'], borderRadius: BorderRadius.circular(4), border: Border.all(color: data['border'] as Color, width: 0.8)),
      child: Center(child: Icon(data['icon'] as IconData, size: 15, color: data['border'] as Color)),
    );
  }

  Map<String, dynamic> _data() {
    switch (category.toLowerCase()) {
      case 'food':
        return {'bg': const Color(0x25FF6B6B), 'border': const Color(0xFFFF6B6B), 'icon': Icons.fastfood};
      case 'travel':
        return {'bg': const Color(0x354FC3F7), 'border': const Color(0xFF4FC3F7), 'icon': Icons.directions_car};
      case 'supplies':
        return {'bg': const Color(0x25EFA169), 'border': const Color(0xFFEFA169), 'icon': Icons.shopping_cart};
      case 'bills':
        return {'bg': const Color(0x30FFB347), 'border': const Color(0xFFFFB347), 'icon': Icons.receipt_long};
      case 'entertainment':
        return {'bg': const Color(0x25CE93D8), 'border': const Color(0xFFCE93D8), 'icon': Icons.movie};
      case 'medical':
        return {'bg': const Color(0x2581C784), 'border': const Color(0xFF81C784), 'icon': Icons.local_pharmacy};
      case 'education':
        return {'bg': const Color(0x254DB6AC), 'border': const Color(0xFF4DB6AC), 'icon': Icons.school};
      case 'rent':
        return {'bg': const Color(0x30FFD54F), 'border': const Color(0xFFFFD54F), 'icon': Icons.home};
      case 'petrol':
        return {'bg': const Color(0x25FF8A65), 'border': const Color(0xFFFF8A65), 'icon': Icons.local_gas_station};
      case 'electricity':
        return {'bg': const Color(0x30FDD835), 'border': const Color(0xFFFDD835), 'icon': Icons.electric_bolt};
      case 'home services':
        return {'bg': const Color(0x2590CAF9), 'border': const Color(0xFF90CAF9), 'icon': Icons.home_repair_service};
      default:
        return {'bg': const Color(0x2590A4AE), 'border': const Color(0xFF90A4AE), 'icon': Icons.category};
    }
  }
}

// ── Comparison Row ────────────────────────────────────────────────────────────

class _CmpRow extends StatelessWidget {
  final String amount, label;
  const _CmpRow({required this.amount, required this.label});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '  $amount ', style: const TextStyle(color: Color(0xFF5F5F5F), fontSize: 13, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
          TextSpan(text: label,        style: const TextStyle(color: Color(0xFF8E8E8E), fontSize: 13, fontFamily: 'Poppins', fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

// ── Weekly Summary ────────────────────────────────────────────────────────────

class _WeeklySummary extends StatelessWidget {
  final ExpenseProvider provider;
  const _WeeklySummary({required this.provider});

  @override
  Widget build(BuildContext context) {
    final weekTotal = provider.thisWeekTotal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
      child: Text(
        'This week:  ₹ ${weekTotal.toStringAsFixed(0)}  Spent',
        style: const TextStyle(color: Color(0xFF5A5A5A), fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Gauge Painter ─────────────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height * 0.88;
    final r  = size.width * 0.40;

    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      startAngle, sweepAngle, false,
      Paint()..color = const Color(0xFFDDE3EA)..strokeWidth = 10..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );

    // Fill (40%)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      startAngle, sweepAngle * 0.4, false,
      Paint()..color = const Color(0xFF4D8BC6)..strokeWidth = 10..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
