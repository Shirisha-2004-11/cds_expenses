import 'package:flutter/material.dart';
// ── Centralised theme tokens ─────────────────────────────────────────────────
// ignore: unused_import
import '../theme/dashboard_colors.dart';
// ignore: unused_import
import '../theme/dashboard_text_styles.dart';
// ignore: unused_import
import '../widgets/common/dashboard_card.dart';
// ignore: unused_import
import '../widgets/common/dashboard_period_picker_button.dart';

class MonthlyAnalyticsCard extends StatefulWidget {
  const MonthlyAnalyticsCard({super.key});

  @override
  State<MonthlyAnalyticsCard> createState() => _MonthlyAnalyticsCardState();
}

class _MonthlyAnalyticsCardState extends State<MonthlyAnalyticsCard> {
  String selectedPeriod = 'This year';

  // ── Dynamic Data Maps ────────────────────────────────────────────────────────
  // Change these values to update the graph automatically

  final Map<String, List<double>> periodData = {
    'This year': [8000, 9500, 14480, 11000, 12800, 10500, 9800, 13200, 11500, 10200, 14000, 12500],
    'Last year': [6000, 7200, 9800, 8500, 10200, 9000, 8800, 11000, 9500, 8200, 11500, 10000],
    'Last 6 months': [11000, 12800, 10500, 9800, 13200, 14480],
    'Last 3 months': [10500, 9800, 14480],
  };

  final Map<String, List<String>> periodLabels = {
    'This year': ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'],
    'Last year': ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'],
    'Last 6 months': ['NOV', 'DEC', 'JAN', 'FEB', 'MAR', 'APR'],
    'Last 3 months': ['FEB', 'MAR', 'APR'],
  };

  // Returns index of the highest value (peak point on graph)
  int get _highlightIndex {
    final data = periodData[selectedPeriod]!;
    double maxVal = data[0];
    int maxIndex = 0;
    for (int i = 1; i < data.length; i++) {
      if (data[i] > maxVal) {
        maxVal = data[i];
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  // Current month total (last value in list)
  double get _currentMonthTotal {
    return periodData[selectedPeriod]!.last;
  }

  // Previous period total for % change calculation
  double get _previousMonthTotal {
    final data = periodData[selectedPeriod]!;
    if (data.length < 2) return data.first;
    return data[data.length - 2];
  }

  // Percentage change
  double get _percentChange {
    if (_previousMonthTotal == 0) return 0;
    return ((_currentMonthTotal - _previousMonthTotal) / _previousMonthTotal) * 100;
  }

  bool get _isIncrease => _percentChange >= 0;

  @override
  Widget build(BuildContext context) {
    final data = periodData[selectedPeriod]!;
    final labels = periodLabels[selectedPeriod]!;
    final percent = _percentChange.abs().toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          // ── Title Row ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly analytics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              GestureDetector(
                onTap: () => _showPeriodPicker(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        selectedPeriod,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          const Text(
            'Total spent this month',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // ── Dynamic Amount + % Badge ───────────────────────────────────────
          Row(
            children: [
              Text(
                '₹ ${_formatAmount(_currentMonthTotal)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isIncrease
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.12)
                      : const Color(0xFFE53935).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 11,
                      color: _isIncrease
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isIncrease
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Dynamic Line Chart ─────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: SizedBox(
              key: ValueKey(selectedPeriod),
              height: 110,
              child: CustomPaint(
                size: const Size(double.infinity, 110),
                painter: _LineChartPainter(
                  data: data,
                  labels: labels,
                  highlightIndex: _highlightIndex,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Format large numbers: 14480 → 14,480
  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      final formatted = amount.toStringAsFixed(0);
      if (formatted.length > 3) {
        return '${formatted.substring(0, formatted.length - 3)},${formatted.substring(formatted.length - 3)}';
      }
      return formatted;
    }
    return amount.toStringAsFixed(0);
  }

  void _showPeriodPicker() {
    final options = ['This year', 'Last year', 'Last 6 months', 'Last 3 months'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Period',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...options.map(
              (o) => ListTile(
                title: Text(o),
                trailing: selectedPeriod == o
                    ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                    : null,
                onTap: () {
                  setState(() => selectedPeriod = o);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Line Chart Painter ──────────────────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final int highlightIndex;

  _LineChartPainter({
    required this.data,
    required this.labels,
    required this.highlightIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);
    final double chartHeight = size.height - 22;
    final double stepX = size.width / (data.length - 1);

    List<Offset> points = List.generate(data.length, (i) {
      return Offset(
        i * stepX,
        chartHeight - ((data[i] - minVal) / range) * chartHeight,
      );
    });

    // Gradient fill
    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    fillPath
      ..lineTo(points.last.dx, chartHeight)
      ..lineTo(points.first.dx, chartHeight)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4A90D9).withValues(alpha: 0.25),
            const Color(0xFF4A90D9).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight)),
    );

    // Smooth line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF4A90D9)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Highlight dot at peak
    final hp = points[highlightIndex];
    canvas.drawCircle(hp, 7, Paint()..color = const Color(0xFF4A90D9));
    canvas.drawCircle(hp, 5, Paint()..color = Colors.white);

    // Month labels — only show if not too crowded
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final showEvery = data.length > 6 ? 2 : 1; // skip labels if too many months

    for (int i = 0; i < labels.length; i++) {
      if (i % showEvery != 0 && i != highlightIndex) continue;
      final isHighlight = i == highlightIndex;
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          fontSize: 10,
          color: isHighlight ? const Color(0xFF4A90D9) : Colors.grey,
          fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(points[i].dx - tp.width / 2, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}