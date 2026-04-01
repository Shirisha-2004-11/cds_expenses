import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpendingInsightsScreen extends StatelessWidget {
  const SpendingInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF1F5),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Spending insights',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: const [
            _TopCard(),
            SizedBox(height: 12),
            _BreakdownCard(),
            SizedBox(height: 12),
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
  static const _heights = [0.28, 0.22, 0.18, 0.30, 0.24, 0.19, 0.36, 0.95, 0.42, 0.55];
  static const _dates   = [
    '20 Mar (tue)', '21 Mar (wed)', '22 Mar (thu)', '23 Mar (fri)',
    '24 Mar (sat)', '25 Mar (sun)', '26 Mar (mon)', '27 Mar (mon)',
    '28 Mar (tue)', '29 Mar (wed)',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: gauge card + tooltip ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gauge card — light background, matches Image 2
              Container(
                width: 140,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F3F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 68,
                      child: CustomPaint(painter: _GaugePainter()),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'High spend day',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      '₹ 830  Spent',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Above your daily average',
                      style: TextStyle(color: Colors.grey, fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Tooltip card — right side, rounded with shadow
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8EDF3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '₹ ${_amounts[_activeIndex]}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _dates[_activeIndex],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '+18% vs avg',
                        style: TextStyle(
                          color: Color(0xFF00BFA5),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Bar chart with inline tooltip pointer above active bar ──────────
          _InteractiveBarChart(
            days: _days,
            heights: _heights,
            amounts: _amounts,
            activeIndex: _activeIndex,
            onTap: (i) => setState(() => _activeIndex = i),
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
    const maxH    = 80.0;
    const labelH  = 14.0;
    const dotH    = 10.0;
    const totalH  = maxH + dotH + labelH + 4;

    return SizedBox(
      height: totalH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(days.length, (i) {
          final isActive = i == activeIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => onTap(i),
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
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF42A5F5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    // Bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 20,
                      height: maxH * heights[i],
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF42A5F5)
                            : const Color(0xFFBDD9F2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Date label
                    SizedBox(
                      height: labelH,
                      child: Text(
                        days[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isActive
                              ? const Color(0xFF1565C0)
                              : Colors.grey,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Gauge Painter ─────────────────────────────────────────────────────────────
// Matches Image 2:
//   • Light grey filled half-disc background
//   • Thick arc band: green(small) | teal(dominant) | orange | red(small)
//   • Dark needle pointing toward orange/right-of-centre
//   • Dark filled pivot + white centre

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx     = size.width / 2;
    final cy     = size.height;
    final outerR = size.width / 2 - 2;
    const sw     = 15.0;

    // 1. Light grey filled half-disc
    final discPath = Path();
    discPath.moveTo(cx - outerR - sw / 2, cy);
    discPath.arcTo(
      Rect.fromCircle(center: Offset(cx, cy), radius: outerR + sw / 2 + 1),
      math.pi, math.pi, false,
    );
    discPath.lineTo(cx, cy);
    discPath.close();
    canvas.drawPath(discPath, Paint()..color = const Color(0xFFDDE3EC));

    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: outerR);

    // 2. Dark grey base track (background of band)
    canvas.drawArc(arcRect, math.pi, math.pi, false,
      Paint()
        ..color = const Color(0xFF8E9BAA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.butt,
    );

    // 3. Coloured segments: green | teal(dominant) | orange | red
    final segs = [
      _Seg(math.pi,        math.pi * 0.17, const Color(0xFF43A047)), // green
      _Seg(math.pi * 1.17, math.pi * 0.46, const Color(0xFF00897B)), // teal dominant
      _Seg(math.pi * 1.63, math.pi * 0.21, const Color(0xFFFB8C00)), // orange
      _Seg(math.pi * 1.84, math.pi * 0.16, const Color(0xFFE53935)), // red
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

    // 4. Light grey dividers (matching disc bg)
    for (final a in [math.pi * 1.17, math.pi * 1.63, math.pi * 1.84]) {
      final x1 = cx + (outerR - sw / 2 - 1) * math.cos(a);
      final y1 = cy + (outerR - sw / 2 - 1) * math.sin(a);
      final x2 = cx + (outerR + sw / 2 + 1) * math.cos(a);
      final y2 = cy + (outerR + sw / 2 + 1) * math.sin(a);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2),
          Paint()..color = const Color(0xFFDDE3EC)..strokeWidth = 2.5);
    }

    // 5. Needle — pointing toward orange zone (~300°)
    const na = math.pi * 1.70;
    final nl = outerR - 4.0;
    final nx = cx + nl * math.cos(na);
    final ny = cy + nl * math.sin(na);

    // shadow
    canvas.drawLine(
        Offset(cx + 0.7, cy + 0.5), Offset(nx + 0.7, ny + 0.5),
        Paint()
          ..color = Colors.black26
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round);
    // needle body
    canvas.drawLine(Offset(cx, cy), Offset(nx, ny),
        Paint()
          ..color = const Color(0xFF263238)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round);

    // 6. Pivot
    canvas.drawCircle(Offset(cx, cy), 6.0,
        Paint()..color = const Color(0xFF263238));
    canvas.drawCircle(Offset(cx, cy), 2.8,
        Paint()..color = Colors.white);
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '27 march breakdown',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
          const SizedBox(height: 10),
          Row(children: const [
            Expanded(
              child: _CatTile(
                icon: Icons.local_taxi,
                label: 'Cabs',
                amount: '₹ 180',
                bg: Color(0xFFE3F2FD),
                iconColor: Color(0xFF1E88E5),
              ),
            ),
            SizedBox(width: 6),
            Expanded(
              child: _CatTile(
                icon: Icons.receipt_long,
                label: 'Bills',
                amount: '₹ 180',
                bg: Color(0xFFEDE7F6),
                iconColor: Color(0xFF7B1FA2),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: const [
            Expanded(
              child: _CatTile(
                icon: Icons.lunch_dining,
                label: 'Lunch',
                amount: '₹ 220',
                bg: Color(0xFFFFF8E1),
                iconColor: Color(0xFFF57F17),
              ),
            ),
            SizedBox(width: 6),
            Expanded(
              child: _CatTile(
                icon: Icons.shopping_cart_outlined,
                label: 'Supplies',
                amount: '₹ 220',
                bg: Color(0xFFE8F5E9),
                iconColor: Color(0xFF388E3C),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),
          const Text(
            'Compared to your average day',
            style: TextStyle(color: Colors.grey, fontSize: 11.5),
          ),
          const SizedBox(height: 5),
          const _CmpRow(label: '₹ 180   more on food'),
          const SizedBox(height: 3),
          const _CmpRow(label: '₹ 90    more on cabs'),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.black87, fontSize: 12),
              children: [
                TextSpan(
                  text: 'Biggest contributor : ',
                  style: TextStyle(color: Colors.grey),
                ),
                TextSpan(
                  text: 'cabs',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'You spent 40% on travel more than usual',
            style: TextStyle(color: Colors.grey, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _CatTile extends StatelessWidget {
  final IconData icon;
  final String label, amount;
  final Color bg;
  final Color iconColor;

  const _CatTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 13, color: iconColor),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(amount,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CmpRow extends StatelessWidget {
  final String label;
  const _CmpRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.arrow_upward, size: 12, color: Color(0xFFE53935)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 13.5, color: Colors.black87),
          children: [
            TextSpan(text: 'This week: '),
            TextSpan(
              text: '₹14,480 Spent',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}