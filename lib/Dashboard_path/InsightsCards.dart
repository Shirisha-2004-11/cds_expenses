import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpendingInsightsScreen extends StatelessWidget {
  const SpendingInsightsScreen({super.key});

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
          style: TextStyle(
            color: Color(0xFF5A5A5A),
            fontWeight: FontWeight.w600,
            fontSize: 20,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: const [
            _TopCard(),
            SizedBox(height: 12),
            _BreakdownCard(),
            SizedBox(height: 16),
            _WeeklySummary(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Top Card ──────────────────────────────────────────────────────────────────

class _TopCard extends StatefulWidget {
  const _TopCard();
  @override
  State<_TopCard> createState() => _TopCardState();
}

class _TopCardState extends State<_TopCard> {
  int _activeIndex = 7; // 27 Mar default

  static const _days    = ['20','21','22','23','24','25','26','27','28','29'];
  static const _amounts = [230, 180, 150, 250, 200, 155, 300, 830, 350, 460];
  static const _heights = [0.28, 0.22, 0.18, 0.30, 0.24, 0.19, 0.36, 1.0, 0.42, 0.55];
  static const _dates   = [
    '20 Mar (tue)', '21 Mar (wed)', '22 Mar (thu)', '23 Mar (fri)',
    '24 Mar (sat)', '25 Mar (sun)', '26 Mar (mon)', '27 Mar (mon)',
    '28 Mar (tue)', '29 Mar (wed)',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top section: gauge (left) + tooltip (right) ──────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT: gauge card with light background
                Container(
                  width: 150,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF1F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(13),
                      bottomLeft: Radius.circular(0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gauge
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 85,
                          child: CustomPaint(painter: _GaugePainter()),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'High spend day',
                        style: TextStyle(
                          color: Color(0xFF750909),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '\u20b9 830  Spent',
                        style: TextStyle(
                          color: Color(0xFF5F5F5F),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Above your daily average',
                        style: TextStyle(
                          color: Color(0xFF5F5F5F),
                          fontSize: 9,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // RIGHT: tooltip showing selected bar info
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(13),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dates[_activeIndex],
                          style: const TextStyle(
                            color: Color(0xFF5F5F5F),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\u20b9 ${_amounts[_activeIndex]}',
                          style: const TextStyle(
                            color: Color(0xFF2E2E2E),
                            fontSize: 26,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Spent today',
                          style: TextStyle(
                            color: Color(0xFF8E8E8E),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider line ─────────────────────────────────────────────────
          Container(height: 1, color: const Color(0xFFE0E0E0)),

          // ── Bar chart ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
            child: _InteractiveBarChart(
              days: _days,
              heights: _heights,
              amounts: _amounts,
              activeIndex: _activeIndex,
              onTap: (i) => setState(() => _activeIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Interactive Bar Chart ─────────────────────────────────────────────────────

class _InteractiveBarChart extends StatelessWidget {
  final List<String> days;
  final List<double> heights;
  final List<int> amounts;
  final int activeIndex;
  final ValueChanged<int> onTap;

  const _InteractiveBarChart({
    required this.days,
    required this.heights,
    required this.amounts,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const maxH   = 100.0;
    const labelH = 18.0;
    const dotH   = 14.0;
    const totalH = maxH + dotH + labelH + 4;

    return SizedBox(
      height: totalH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(days.length, (i) {
          final isActive = i == activeIndex;

          // Active bar: solid steel blue. Others: light cyan, fading right
          Color barColor;
          if (isActive) {
            barColor = const Color(0xFF5B9EC9); // solid darker blue for active
          } else {
            barColor = const Color(0xFFAEE3EF); // uniform light teal for all others
          }

          return GestureDetector(
            onTap: () => onTap(i),
            child: SizedBox(
              width: 26,
              height: totalH,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Dot above active bar only
                  SizedBox(
                    height: dotH,
                    child: isActive
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF5B9EC9),
                                  width: 2,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  // Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: maxH * heights[i],
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFF5B9EC9).withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date label
                  SizedBox(
                    height: labelH,
                    child: Text(
                      days[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        color: isActive
                            ? const Color(0xFF2E2E2E)
                            : const Color(0xAA5A5A5A),
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Gauge Painter ─────────────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx     = size.width / 2;
    final cy     = size.height;          // baseline at bottom
    final outerR = size.width / 2 - 4;
    const sw     = 16.0;

    // 1. Background half-disc
    final discPath = Path()
      ..moveTo(0, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: outerR + sw / 2 + 2),
        math.pi, math.pi, false,
      )
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(discPath, Paint()..color = const Color(0xFFEEF1F5));

    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: outerR);

    // 2. Grey base track
    canvas.drawArc(arcRect, math.pi, math.pi, false,
      Paint()
        ..color = const Color(0xFF9E9E9E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.butt,
    );

    // 3. Coloured segments: small green | large teal | grey (right, already from base track)
    final segs = [
      _Seg(math.pi,        math.pi * 0.14, const Color(0xFF3DAA55)), // green (small, far left)
      _Seg(math.pi * 1.14, math.pi * 0.56, const Color(0xFF1D8F86)), // teal (dominant center)
      // right portion stays grey from the base track drawn above
    ];
    for (final s in segs) {
      canvas.drawArc(arcRect, s.start, s.sweep, false,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.butt,
      );
    }

    // 4. Segment dividers
    for (final a in [math.pi * 1.14, math.pi * 1.70]) {
      final x1 = cx + (outerR - sw / 2 - 2) * math.cos(a);
      final y1 = cy + (outerR - sw / 2 - 2) * math.sin(a);
      final x2 = cx + (outerR + sw / 2 + 2) * math.cos(a);
      final y2 = cy + (outerR + sw / 2 + 2) * math.sin(a);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2),
          Paint()..color = const Color(0xFFEEF1F5)..strokeWidth = 3);
    }

    // 5. Needle — pointing into orange zone (~295°)
    const needleAngle = math.pi * 1.78;
    final needleLen   = outerR - 6.0;
    final nx = cx + needleLen * math.cos(needleAngle);
    final ny = cy + needleLen * math.sin(needleAngle);

    // Shadow
    canvas.drawLine(
      Offset(cx + 1, cy + 1), Offset(nx + 1, ny + 1),
      Paint()
        ..color = Colors.black26
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    // Needle body
    canvas.drawLine(
      Offset(cx, cy), Offset(nx, ny),
      Paint()
        ..color = const Color(0xFF2A2A2A)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // 6. Pivot circles
    canvas.drawCircle(Offset(cx, cy), 7,
        Paint()..color = const Color(0xFF555A6F));
    canvas.drawCircle(Offset(cx, cy), 4,
        Paint()..color = const Color(0xFFA1A1A1));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Seg {
  final double start, sweep;
  final Color color;
  const _Seg(this.start, this.sweep, this.color);
}

// ── Breakdown Card ────────────────────────────────────────────────────────────

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            '27 march breakdown',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'Poppins',
              color: Color(0xFF5A5A5A),
            ),
          ),
          const SizedBox(height: 16),

          // Row 1: Cabs | Bills
          Row(children: const [
            Expanded(child: _CatTile(iconWidget: _CabIcon(),   label: 'Cabs',     amount: '\u20b9 180')),
            SizedBox(width: 12),
            Expanded(child: _CatTile(iconWidget: _BillIcon(),  label: 'Bills',    amount: '\u20b9 180')),
          ]),
          const SizedBox(height: 10),

          // Row 2: Lunch | Supplies
          Row(children: const [
            Expanded(child: _CatTile(iconWidget: _LunchIcon(),  label: 'Lunch',    amount: '\u20b9 220')),
            SizedBox(width: 12),
            Expanded(child: _CatTile(iconWidget: _SupplyIcon(), label: 'Supplies', amount: '\u20b9 220')),
          ]),

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFDDDDDD)),
          const SizedBox(height: 12),

          // Compared section
          const Text(
            'Compared to your average day',
            style: TextStyle(
              color: Color(0xFF8E8E8E),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          const _CmpRow(amount: '\u20b9 180', label: 'more on food'),
          const SizedBox(height: 5),
          const _CmpRow(amount: '\u20b9 90',  label: 'more on cabs'),

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFDDDDDD)),
          const SizedBox(height: 12),

          // Biggest contributor
          const Text(
            'Biggest contributor : cabs',
            style: TextStyle(
              color: Color(0xFF8E8E8E),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'You spent 40% on travel more than usual',
            style: TextStyle(
              color: Color(0xFF8E8E8E),
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Tile ─────────────────────────────────────────────────────────────

class _CatTile extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String amount;
  const _CatTile({required this.iconWidget, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        iconWidget,
        const SizedBox(width: 10),
        Text(
          '$label   $amount',
          style: const TextStyle(
            color: Color(0xFF5F5F5F),
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Icon Boxes (matching Figma border colors) ─────────────────────────────────

class _CabIcon extends StatelessWidget {
  const _CabIcon();
  @override
  Widget build(BuildContext context) => _IconBox(
    color: const Color(0x354D8CC6), border: const Color(0xFF4D8BC6),
    child: const Icon(Icons.local_taxi, size: 15, color: Color(0xFF4D8BC6)),
  );
}

class _BillIcon extends StatelessWidget {
  const _BillIcon();
  @override
  Widget build(BuildContext context) => _IconBox(
    color: const Color(0x0FA17BF1), border: const Color(0xFFA17BF1),
    child: const Icon(Icons.receipt_long, size: 15, color: Color(0xFFA17BF1)),
  );
}

class _LunchIcon extends StatelessWidget {
  const _LunchIcon();
  @override
  Widget build(BuildContext context) => _IconBox(
    color: const Color(0x23D7A624), border: const Color(0xFFC39721),
    child: const Icon(Icons.lunch_dining, size: 15, color: Color(0xFFC39721)),
  );
}

class _SupplyIcon extends StatelessWidget {
  const _SupplyIcon();
  @override
  Widget build(BuildContext context) => _IconBox(
    color: const Color(0x1EEFA169), border: const Color(0xFFEFA169),
    child: const Icon(Icons.shopping_bag_outlined, size: 15, color: Color(0xFFEFA169)),
  );
}

class _IconBox extends StatelessWidget {
  final Color color, border;
  final Widget child;
  const _IconBox({required this.color, required this.border, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 30,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: border, width: 0.8),
    ),
    child: Center(child: child),
  );
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
          TextSpan(
            text: '  $amount ',
            style: const TextStyle(
              color: Color(0xFF5F5F5F),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(
              color: Color(0xFF8E8E8E),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly Summary ────────────────────────────────────────────────────────────

class _WeeklySummary extends StatelessWidget {
  const _WeeklySummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Text(
        'This week:  \u20b9 14,480  Spent',
        style: TextStyle(
          color: Color(0xFF5A5A5A),
          fontSize: 14,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
