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

// ─── Spending Summary Row ─────────────────────────────────────────────────────

class SpendingSummaryRow extends StatelessWidget {
  const SpendingSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left Card: Highest spending category ──
        Expanded(
          child: _SummaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Highest spending category',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF8FAA98),
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Amount
                const Text(
                  '₹ 4,050',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2E22),
                    letterSpacing: -0.3,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),

                // Category
                const Text(
                  'Food',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A6358),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // Divider
                const Divider(color: Color(0xFFECF2EE), height: 1),
                const SizedBox(height: 10),

                // Tag pill
                _TagPill(label: '+380 /day in march'),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ── Right Card: Daily Spending Avg ──
        Expanded(
          child: _SummaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Daily Spending . Avg',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF8FAA98),
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Amount + /day
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      '₹ 482',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2E22),
                        letterSpacing: -0.3,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '/day',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8FAA98),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Subtitle
                const Text(
                  '+410/day in march',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8FAA98),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const Spacer(),

                // View button
                _ViewButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Card Shell ───────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final Widget child;
  const _SummaryCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2A7A50),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Tag Pill ─────────────────────────────────────────────────────────────────

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCEDE4), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          color: Color(0xFF4A6358),
          fontWeight: FontWeight.w500,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ─── View Button ─────────────────────────────────────────────────────────────

class _ViewButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFE4F2EA),
          foregroundColor: const Color(0xFF2A7A50),
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'View',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}