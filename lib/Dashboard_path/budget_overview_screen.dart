// ─────────────────────────────────────────────────────────────────────────────
// lib/Dashboard_path/budget_overview_screen.dart  (UPDATED — fully dynamic)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/expense_provider.dart';

// ─── Main screen ──────────────────────────────────────────────────────────────

class BudgetOverviewScreen extends StatelessWidget {
  final ExpenseProvider provider;

  const BudgetOverviewScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final categories   = provider.sortedCategories;
    final totalSpent   = provider.totalSpentThisMonth;
    final totalBudget  = provider.totalBudget;
    final now          = DateTime.now();
    final monthNames   = const ['','January','February','March','April','May','June','July','August','September','October','November','December'];

    // Build donut colors list aligned to sorted categories
    final List<Color> catColors = categories.map((e) {
      final dummy = Expense(id:'', category: e.key, merchant:'', date:'', note:'', amount:0, paymentMethod:'');
      return dummy.color;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // ── Header ──
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)]),
                    child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF333333)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Budget Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              ],
            ),
            const SizedBox(height: 20),

            // ── Month + Donut ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${monthNames[now.month]} ${now.year}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
                        child: Text('₹ ${totalSpent.toStringAsFixed(0)} spent',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Donut + legend
                  Row(
                    children: [
                      SizedBox(
                        width: 130, height: 130,
                        child: categories.isEmpty
                            ? const Center(child: Text('No data', style: TextStyle(color: Colors.grey, fontSize: 12)))
                            : CustomPaint(
                                painter: _DonutPainter(
                                  values: categories.map((e) => e.value).toList(),
                                  colors: catColors,
                                  total:  totalSpent,
                                ),
                              ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: List.generate(
                            math.min(categories.length, 5),
                            (i) {
                              final e = categories[i];
                              final pct = totalSpent > 0 ? (e.value / totalSpent * 100).toStringAsFixed(0) : '0';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(width: 10, height: 10,
                                        decoration: BoxDecoration(color: catColors[i], shape: BoxShape.circle)),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13, color: Color(0xFF444444)))),
                                    Text('$pct%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (totalBudget > 0) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budget: ₹ ${totalBudget.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        Text('Remaining: ₹ ${(totalBudget - totalSpent).toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                color: totalSpent > totalBudget ? const Color(0xFFE53935) : const Color(0xFF2A7A50))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (totalSpent / totalBudget).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF0F0F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            totalSpent / totalBudget > 0.85 ? const Color(0xFFE53935) : const Color(0xFF2A7A50)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Category breakdown rows ──
            if (categories.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('No expenses this month', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              )
            else ...[
              const Text('Category Breakdown',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 10),
              ...List.generate(categories.length, (i) {
                final e         = categories[i];
                final pct       = totalSpent > 0 ? (e.value / totalSpent * 100).round() : 0;
                final dummy     = Expense(id:'', category: e.key, merchant:'', date:'', note:'', amount:0, paymentMethod:'');
                return _CategoryRow(
                  label:      e.key,
                  icon:       dummy.icon,
                  iconBg:     dummy.color.withValues(alpha: 0.15),
                  iconColor:  dummy.color,
                  amount:     e.value,
                  percent:    pct,
                );
              }),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Category Row ─────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final String   label;
  final IconData icon;
  final Color    iconBg;
  final Color    iconColor;
  final double   amount;
  final int      percent;

  const _CategoryRow({
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.amount,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                    Text('₹ ${amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (percent / 100).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$percent% of total spend',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Donut Painter ────────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color>  colors;
  final double       total;

  const _DonutPainter({required this.values, required this.colors, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const sw     = 18.0;
    double angle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - sw / 2),
        angle, sweep - 0.06, false,
        Paint()
          ..color       = colors[i % colors.length]
          ..strokeWidth = sw
          ..style       = PaintingStyle.stroke
          ..strokeCap   = StrokeCap.round,
      );
      angle += sweep;
    }

    // Centre label
    final tp = TextPainter(
      text: TextSpan(
        text: '₹${_compact(total)}',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  String _compact(double n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000)   return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => true;
}
