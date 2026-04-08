// ─────────────────────────────────────────────────────────────────────────────
// lib/Dashboard_path/Monthly_analystics.dart  (UPDATED — fully dynamic)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ─── Helper ──────────────────────────────────────────────────────────────────

String fmtINR(double n) {
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

// ─── Monthly Analytics Card ───────────────────────────────────────────────────

/// [monthlyTrend] — list of 5 maps from ExpenseProvider.monthlyTrend:
///   { 'month': 'MAR', 'shortMonth': 'Mar', 'amount': 14480.0, ... }
class MonthlyAnalyticsCard extends StatefulWidget {
  final List<Map<String, dynamic>> monthlyTrend;

  const MonthlyAnalyticsCard({
    super.key,
    required this.monthlyTrend,
  });

  @override
  State<MonthlyAnalyticsCard> createState() => _MonthlyAnalyticsCardState();
}

class _MonthlyAnalyticsCardState extends State<MonthlyAnalyticsCard> {
  int _activeIdx = 4; // default to most recent month

  List<double> get _amounts =>
      widget.monthlyTrend.map((m) => (m['amount'] as num).toDouble()).toList();

  List<String> get _months =>
      widget.monthlyTrend.map((m) => m['month'] as String).toList();

  List<String> get _shortMonths =>
      widget.monthlyTrend.map((m) => m['shortMonth'] as String).toList();

  int get _safeIdx => _activeIdx.clamp(0, (_amounts.length - 1).clamp(0, 100));

  /// Returns the real previous month's amount for a given index.
  /// If no previous month exists (first entry), returns 0.
  double _prevAmount(int idx) {
    if (idx > 0) {
      return (widget.monthlyTrend[idx - 1]['amount'] as num).toDouble();
    }
    return 0.0;
  }

  /// Builds a list of previous-month amounts aligned to [_amounts].
  /// Index 0 has no prior month, so it gets 0.0.
  List<double> get _prevAmounts =>
      List.generate(_amounts.length, (i) => _prevAmount(i));

  @override
  Widget build(BuildContext context) {
    final amounts = _amounts;
    if (amounts.isEmpty) return const SizedBox.shrink();

    final idx       = _safeIdx;
    final c         = amounts[idx];
    final p         = _prevAmount(idx); // ✅ real previous month amount
    final diffPct   = p > 0 ? ((c - p) / p * 100).round() : 0;
    final isUp      = diffPct >= 0;
    final prevLabel = idx > 0 ? _shortMonths[idx - 1] : _shortMonths[idx];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x1C2A7A50), blurRadius: 28, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text(
              'Total spent this month',
              style: TextStyle(fontSize: 13, color: Color(0xFF8FAA98), fontWeight: FontWeight.w400),
            ),
          ),

          // ── Chart ──
          _AnalyticsChartSection(
            activeIdx:   idx,
            currAmounts: amounts,
            prevAmounts: _prevAmounts,
            onHover:     (i) => setState(() => _activeIdx = i.clamp(0, amounts.length - 1)),
          ),

          // ── X Axis ──
          _AnalyticsXAxis(
            months:    _months,
            activeIdx: idx,
            onTap:     (i) => setState(() => _activeIdx = i),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fmtINR(c), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Color(0xFF1A2E22), letterSpacing: -0.3, fontFeatures: [FontFeature.tabularFigures()])),
                    const SizedBox(height: 2),
                    Text('in ${_shortMonths[idx]}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF8FAA98))),
                    if (p > 0) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text('Vs \$prevLabel \${fmtINR(p)}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF8FAA98))),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUp ? const Color(0xFFE4F2EA) : const Color(0xFFFDEAEA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '\${isUp ? \'+\' : \'\'}$diffPct%',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isUp ? const Color(0xFF2A7A50) : const Color(0xFFC0392B), fontFeatures: const [FontFeature.tabularFigures()]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                if (p > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: isUp ? const Color(0xFFE4F2EA) : const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isUp ? '↑' : '↓', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isUp ? const Color(0xFF2A7A50) : const Color(0xFFC0392B))),
                        const SizedBox(width: 4),
                        Text('\${diffPct.abs()}%', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: isUp ? const Color(0xFF2A7A50) : const Color(0xFFC0392B), fontFeatures: const [FontFeature.tabularFigures()])),
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

class _AnalyticsChartSection extends StatelessWidget {
  final int activeIdx;
  final List<double> currAmounts;
  final List<double> prevAmounts;
  final ValueChanged<int> onHover;

  const _AnalyticsChartSection({
    required this.activeIdx,
    required this.currAmounts,
    required this.prevAmounts,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final width  = constraints.maxWidth;
        const height = 150.0;
        return SizedBox(
          width: width, height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: _AnalyticsChartPainter(
                  activeIdx:   activeIdx,
                  currAmounts: currAmounts,
                  prevAmounts: prevAmounts,
                ),
              ),
              _FloatingPill(
                activeIdx:   activeIdx,
                currAmounts: currAmounts,
                prevAmounts: prevAmounts,
                chartWidth:  width,
                chartHeight: height,
              ),
              // Gesture layer
              Row(
                children: List.generate(currAmounts.length, (i) => Expanded(
                  child: GestureDetector(
                    onTapDown:  (_) => onHover(i),
                    onPanUpdate: (_) => onHover(i),
                    child: Container(color: Colors.transparent),
                  ),
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Chart Painter ────────────────────────────────────────────────────────────

class _AnalyticsChartPainter extends CustomPainter {
  final int activeIdx;
  final List<double> currAmounts;
  final List<double> prevAmounts;
  const _AnalyticsChartPainter({required this.activeIdx, required this.currAmounts, required this.prevAmounts});

  static const double _padL = 16, _padR = 16, _padT = 38, _padB = 16;

  List<Offset> _getPoints(List<double> vals, double mn, double mx, double w, double h) {
    if (vals.length < 2) return [];
    return List.generate(vals.length, (i) {
      final x = _padL + i / (vals.length - 1) * (w - _padL - _padR);
      final range = mx - mn;
      final y = range > 0
          ? _padT + (1 - (vals[i] - mn) / range) * (h - _padT - _padB)
          : h / 2;
      return Offset(x, y);
    });
  }

  Path _areaPath(List<Offset> pts, double h) {
    final path = Path();
    if (pts.isEmpty) return path;
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
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path;
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 3.5, gapLen = 3.0;
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

  void _drawDot(Canvas canvas, Offset center, double r, Color fill, Color stroke, double sw) {
    canvas.drawCircle(center, r, Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawCircle(center, r, Paint()..color = stroke..strokeWidth = sw..style = PaintingStyle.stroke);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    if (w <= 0 || h <= 0 || currAmounts.length < 2) return;
    final idx = activeIdx.clamp(0, currAmounts.length - 1);
    final all = [...currAmounts, ...prevAmounts];
    final mn  = all.reduce((a, b) => a < b ? a : b) * 0.87;
    final mx  = all.reduce((a, b) => a > b ? a : b) * 1.07;
    final cPts = _getPoints(currAmounts, mn, mx, w, h);
    final pPts = _getPoints(prevAmounts, mn, mx, w, h);

    canvas.drawPath(_areaPath(pPts, h), Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x388EC4A8), Color(0x058EC4A8)]).createShader(Rect.fromLTWH(0, 0, w, h)));
    canvas.drawPath(_areaPath(cPts, h), Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x2B2A7A50), Color(0x052A7A50)]).createShader(Rect.fromLTWH(0, 0, w, h)));
    canvas.drawPath(_linePath(pPts), Paint()..color = const Color(0xFF8EC4A8)..strokeWidth = 2.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    canvas.drawPath(_linePath(cPts), Paint()..color = const Color(0xFF2A7A50)..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    for (int i = 0; i < pPts.length; i++) {
      _drawDot(canvas, pPts[i], 3.5, Colors.white, const Color(0xFF8EC4A8), 1.6);
    }
    for (int i = 0; i < cPts.length; i++) {
      final up = currAmounts[i] >= prevAmounts[i];
      _drawDot(canvas, cPts[i], 4.5, Colors.white, up ? const Color(0xFF2A7A50) : const Color(0xFFC0392B), 2.0);
    }

    if (idx < cPts.length) {
      _drawDashedLine(canvas, Offset(cPts[idx].dx, _padT - 4), Offset(cPts[idx].dx, h - _padB),
          Paint()..color = const Color(0xA62A7A50)..strokeWidth = 1.2..style = PaintingStyle.stroke);
      final isUp = currAmounts[idx] >= prevAmounts[idx];
      _drawDot(canvas, pPts[idx], 4.5, Colors.white, const Color(0xFF8EC4A8), 1.8);
      _drawDot(canvas, cPts[idx], 5.5, Colors.white, isUp ? const Color(0xFF2A7A50) : const Color(0xFFC0392B), 2.2);
    }
  }

  @override
  bool shouldRepaint(_AnalyticsChartPainter old) => old.activeIdx != activeIdx || old.currAmounts != currAmounts;
}

// ─── Floating Pill ────────────────────────────────────────────────────────────

class _FloatingPill extends StatelessWidget {
  final int activeIdx;
  final List<double> currAmounts;
  final List<double> prevAmounts;
  final double chartWidth, chartHeight;

  const _FloatingPill({required this.activeIdx, required this.currAmounts, required this.prevAmounts, required this.chartWidth, required this.chartHeight});

  static const double _padL = 16, _padR = 16, _padT = 38, _padB = 16;

  @override
  Widget build(BuildContext context) {
    if (chartWidth <= 0 || chartHeight <= 0 || currAmounts.length < 2) return const SizedBox.shrink();
    final idx = activeIdx.clamp(0, currAmounts.length - 1);
    final all = [...currAmounts, ...prevAmounts];
    final mn  = all.reduce((a, b) => a < b ? a : b) * 0.87;
    final mx  = all.reduce((a, b) => a > b ? a : b) * 1.07;
    final range = mx - mn;
    final x = _padL + idx / (currAmounts.length - 1) * (chartWidth - _padL - _padR);
    final y = range > 0 ? _padT + (1 - (currAmounts[idx] - mn) / range) * (chartHeight - _padT - _padB) : chartHeight / 2;
    final c       = currAmounts[idx];
    final p       = prevAmounts[idx];
    final diffPct = p > 0 ? ((c - p) / p * 100).round() : 0;
    final isUp    = diffPct >= 0;
    const pillH = 30.0, pillW = 148.0;
    final left = (x - pillW / 2).clamp(0.0, chartWidth - pillW);
    final top  = y - pillH - 12;

    return Positioned(
      left: left, top: top,
      child: Container(
        height: pillH,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isUp ? const Color(0xFF2A7A50) : const Color(0xFFC0392B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x472A7A50), blurRadius: 12, offset: Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isUp ? '↑' : '↓', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(fmtINR(c), style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
            const SizedBox(width: 5),
            Text('${diffPct.abs()}%', style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─── X Axis ───────────────────────────────────────────────────────────────────

class _AnalyticsXAxis extends StatelessWidget {
  final List<String> months;
  final int activeIdx;
  final ValueChanged<int> onTap;

  const _AnalyticsXAxis({required this.months, required this.activeIdx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Row(
        children: List.generate(months.length, (i) {
          final isActive = i == activeIdx;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFE4F2EA) : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  months[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? const Color(0xFF2A7A50) : const Color(0xFF8FAA98),
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