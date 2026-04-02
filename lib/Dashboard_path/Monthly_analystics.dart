import 'package:flutter/material.dart';

// ─── Data (5 months matching the design) ─────────────────────────────────────

const List<String> kMonths = ['JAN', 'FEB', 'MAR', 'APR', 'MAY'];
const List<String> kShort  = ['Jan', 'Feb', 'Mar', 'Apr', 'MAY'];

const List<double> kCurr = [4800, 12600, 14480, 13200, 11800];
const List<double> kPrev = [3900,  9800, 12600, 11200, 10200];

// ─── Helper ──────────────────────────────────────────────────────────────────

String fmtINR(double n) {
  // Indian number formatting: ₹ 14,480
  final s = n.toInt().toString();
  if (s.length <= 3) return '₹ $s';
  final buf = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buf.write(',');
    buf.write(s[i]);
    count++;
  }
  return '₹ ${buf.toString().split('').reversed.join()}';
}

int _safeIdx(int idx) => idx.clamp(0, kCurr.length - 1);

// ─── Monthly Analytics Card ───────────────────────────────────────────────────

class MonthlyAnalyticsCard extends StatefulWidget {
  const MonthlyAnalyticsCard({super.key});

  @override
  State<MonthlyAnalyticsCard> createState() => _MonthlyAnalyticsCardState();
}

class _MonthlyAnalyticsCardState extends State<MonthlyAnalyticsCard> {
  int _activeIdx = 2; // default to MAR

  @override
  Widget build(BuildContext context) {
    final idx     = _safeIdx(_activeIdx);
    final c       = kCurr[idx];
    final p       = kPrev[idx];
    final diffPct = ((c - p) / p * 100).round();
    final isUp    = diffPct >= 0;
    final prevMon = kShort[idx == 0 ? 0 : idx - 1];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1C2A7A50),
            blurRadius: 28,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Label ──
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text(
              'Total spent this month',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8FAA98),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // ── Chart ──
          AnalyticsChartSection(
            activeIdx: idx,
            onHover: (i) => setState(() => _activeIdx = _safeIdx(i)),
          ),

          // ── X Axis ──
          AnalyticsXAxis(
            activeIdx: idx,
            onTap: (i) => setState(() => _activeIdx = _safeIdx(i)),
          ),

          const SizedBox(height: 6),
          const Divider(height: 1, color: Color(0xFFECF2EE)),

          // ── Bottom Summary ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: amount + vs row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fmtINR(c),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2E22),
                        letterSpacing: -0.3,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'in ${kShort[idx]}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF8FAA98),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          'Vs $prevMon ${fmtINR(p)}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF8FAA98),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isUp
                                ? const Color(0xFFE4F2EA)
                                : const Color(0xFFFDEAEA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${isUp ? '+' : ''}$diffPct%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isUp
                                  ? const Color(0xFF2A7A50)
                                  : const Color(0xFFC0392B),
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Right: big % badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: isUp
                        ? const Color(0xFFE4F2EA)
                        : const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isUp ? '↑' : '↓',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isUp
                              ? const Color(0xFF2A7A50)
                              : const Color(0xFFC0392B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${diffPct.abs()}%',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isUp
                              ? const Color(0xFF2A7A50)
                              : const Color(0xFFC0392B),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
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

// ─── Chart Section ────────────────────────────────────────────────────────────

class AnalyticsChartSection extends StatelessWidget {
  final int activeIdx;
  final ValueChanged<int> onHover;

  const AnalyticsChartSection({
    super.key,
    required this.activeIdx,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final width  = constraints.maxWidth;
        const height = 150.0;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Chart painting
              CustomPaint(
                size: Size(width, height),
                painter: AnalyticsChartPainter(activeIdx: activeIdx),
              ),

              // Floating pill tooltip
              AnalyticsFloatingPill(
                activeIdx: activeIdx,
                chartWidth: width,
                chartHeight: height,
              ),

              // "vs Feb ₹ 12,600" inline label
              AnalyticsVsLabel(
                activeIdx: activeIdx,
                chartWidth: width,
                chartHeight: height,
              ),

              // Gesture layer — one zone per month
              Row(
                children: List.generate(kCurr.length, (i) {
                  return Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => onHover(i),
                      onPanUpdate: (_) => onHover(i),
                      child: Container(color: Colors.transparent),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Chart Painter ────────────────────────────────────────────────────────────

class AnalyticsChartPainter extends CustomPainter {
  final int activeIdx;
  const AnalyticsChartPainter({required this.activeIdx});

  static const double _padL = 16, _padR = 16, _padT = 38, _padB = 16;

  List<Offset> _getPoints(
      List<double> vals, double mn, double mx, double w, double h) {
    return List.generate(vals.length, (i) {
      final x = _padL + i / (vals.length - 1) * (w - _padL - _padR);
      final y = _padT + (1 - (vals[i] - mn) / (mx - mn)) * (h - _padT - _padB);
      return Offset(x, y);
    });
  }

  Path _areaPath(List<Offset> pts, double h) {
    final path = Path();
    path.moveTo(pts.first.dx, h - _padB);
    for (final p in pts) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(pts.last.dx, h - _padB);
    path.close();
    return path;
  }

  Path _linePath(List<Offset> pts) {
    final path = Path();
    path.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path;
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint,
      {double dashLen = 3.5, double gapLen = 3}) {
    final dist = (end - start).distance;
    if (dist == 0) return;
    final nx = (end.dx - start.dx) / dist;
    final ny = (end.dy - start.dy) / dist;
    double drawn = 0;
    Offset cur = start;
    while (drawn < dist) {
      final next = Offset(cur.dx + nx * dashLen, cur.dy + ny * dashLen);
      canvas.drawLine(cur, next, paint);
      cur = Offset(next.dx + nx * gapLen, next.dy + ny * gapLen);
      drawn += dashLen + gapLen;
    }
  }

  void _drawDot(Canvas canvas, Offset center, double r,
      Color fill, Color stroke, double strokeW) {
    canvas.drawCircle(center, r,
        Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawCircle(center, r,
        Paint()
          ..color = stroke
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    if (w <= 0 || h <= 0) return;

    final idx = activeIdx.clamp(0, kCurr.length - 1);

    final all = [...kCurr, ...kPrev];
    final mn  = all.reduce((a, b) => a < b ? a : b) * 0.87;
    final mx  = all.reduce((a, b) => a > b ? a : b) * 1.07;

    final cPts = _getPoints(kCurr, mn, mx, w, h);
    final pPts = _getPoints(kPrev, mn, mx, w, h);

    // ── Previous area ──
    canvas.drawPath(
      _areaPath(pPts, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x388EC4A8), Color(0x058EC4A8)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // ── Current area ──
    canvas.drawPath(
      _areaPath(cPts, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x2B2A7A50), Color(0x052A7A50)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // ── Previous line ──
    canvas.drawPath(
      _linePath(pPts),
      Paint()
        ..color = const Color(0xFF8EC4A8)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ── Current line ──
    canvas.drawPath(
      _linePath(cPts),
      Paint()
        ..color = const Color(0xFF2A7A50)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ── Dots on EVERY point (prev) ──
    for (int i = 0; i < pPts.length; i++) {
      _drawDot(canvas, pPts[i], 3.5,
          Colors.white, const Color(0xFF8EC4A8), 1.6);
    }

    // ── Dots on EVERY point (curr) ──
    for (int i = 0; i < cPts.length; i++) {
      final up  = kCurr[i] >= kPrev[i];
      final col = up ? const Color(0xFF2A7A50) : const Color(0xFFC0392B);
      _drawDot(canvas, cPts[i], 4.5, Colors.white, col, 2.0);
    }

    // ── Active: dashed vertical line ──
    _drawDashedLine(
      canvas,
      Offset(cPts[idx].dx, _padT - 4),
      Offset(cPts[idx].dx, h - _padB),
      Paint()
        ..color = const Color(0xA62A7A50)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    // ── Active: larger dots on top ──
    final isUp = kCurr[idx] >= kPrev[idx];
    _drawDot(canvas, pPts[idx], 4.5,
        Colors.white, const Color(0xFF8EC4A8), 1.8);
    _drawDot(canvas, cPts[idx], 5.5,
        Colors.white,
        isUp ? const Color(0xFF2A7A50) : const Color(0xFFC0392B), 2.2);
  }

  @override
  bool shouldRepaint(AnalyticsChartPainter old) =>
      old.activeIdx != activeIdx;
}

// ─── Floating Pill ────────────────────────────────────────────────────────────

class AnalyticsFloatingPill extends StatelessWidget {
  final int activeIdx;
  final double chartWidth, chartHeight;

  const AnalyticsFloatingPill({
    super.key,
    required this.activeIdx,
    required this.chartWidth,
    required this.chartHeight,
  });

  static const double _padL = 16, _padR = 16, _padT = 38, _padB = 16;

  @override
  Widget build(BuildContext context) {
    if (chartWidth <= 0 || chartHeight <= 0) return const SizedBox.shrink();
    final idx = _safeIdx(activeIdx);

    final all = [...kCurr, ...kPrev];
    final mn  = all.reduce((a, b) => a < b ? a : b) * 0.87;
    final mx  = all.reduce((a, b) => a > b ? a : b) * 1.07;

    final x = _padL +
        idx / (kCurr.length - 1) * (chartWidth - _padL - _padR);
    final y = _padT +
        (1 - (kCurr[idx] - mn) / (mx - mn)) *
            (chartHeight - _padT - _padB);

    final c       = kCurr[idx];
    final p       = kPrev[idx];
    final diffPct = ((c - p) / p * 100).round();
    final isUp    = diffPct >= 0;

    const pillH = 30.0;
    const pillW = 148.0;
    final left = (x - pillW / 2).clamp(0.0, chartWidth - pillW);
    final top  = y - pillH - 12;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        height: pillH,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isUp ? const Color(0xFF2A7A50) : const Color(0xFFC0392B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x472A7A50),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isUp ? '↑' : '↓',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              fmtINR(c),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '${diffPct.abs()}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── VS Label ─────────────────────────────────────────────────────────────────

class AnalyticsVsLabel extends StatelessWidget {
  final int activeIdx;
  final double chartWidth, chartHeight;

  const AnalyticsVsLabel({
    super.key,
    required this.activeIdx,
    required this.chartWidth,
    required this.chartHeight,
  });

  static const double _padL = 16, _padR = 16, _padT = 38, _padB = 16;

  @override
  Widget build(BuildContext context) {
    if (chartWidth <= 0) return const SizedBox.shrink();
    final idx = _safeIdx(activeIdx);

    final all = [...kCurr, ...kPrev];
    final mn  = all.reduce((a, b) => a < b ? a : b) * 0.87;
    final mx  = all.reduce((a, b) => a > b ? a : b) * 1.07;

    final x = _padL +
        idx / (kCurr.length - 1) * (chartWidth - _padL - _padR);
    final y = _padT +
        (1 - (kPrev[idx] - mn) / (mx - mn)) *
            (chartHeight - _padT - _padB);

    final prevMon = kShort[idx == 0 ? 0 : idx - 1];

    // Place label to the right of the prev dot, clamped within bounds
    double left = x + 12;
    if (left + 130 > chartWidth) left = x - 140;
    left = left.clamp(0.0, chartWidth - 130);

    return Positioned(
      left: left,
      top: y - 8, // align near prev dot
      child: Text(
        'vs $prevMon ${fmtINR(kPrev[idx])}',
        style: const TextStyle(
          fontSize: 10.5,
          color: Color(0xFF8FAA98),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ─── X Axis ───────────────────────────────────────────────────────────────────

class AnalyticsXAxis extends StatelessWidget {
  final int activeIdx;
  final ValueChanged<int> onTap;

  const AnalyticsXAxis({
    super.key,
    required this.activeIdx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final idx = _safeIdx(activeIdx);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Row(
        children: List.generate(kMonths.length, (i) {
          final isActive = i == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE4F2EA)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  kMonths[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive
                        ? const Color(0xFF2A7A50)
                        : const Color(0xFF8FAA98),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Demo App ─────────────────────────────────────────────────────────────────

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF0F4F1),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const MonthlyAnalyticsCard(),
          ),
        ),
      ),
    );
  }
}