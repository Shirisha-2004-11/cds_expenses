import 'package:flutter/material.dart';
// ── Centralised theme tokens ─────────────────────────────────────────────────
// ignore: unused_import
import '../theme/dashboard_colors.dart';
// ignore: unused_import
import '../theme/dashboard_text_styles.dart';
// ignore: unused_import
import '../widgets/common/dashboard_card.dart';
// ignore: unused_import
import '../widgets/common/dashboard_icon_box.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: '₹ 14,480 in March',
              subtitle: 'Vs Feb ₹ 12,600  +15%',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Daily Spending, Avg',
              subtitle: '₹ 482 /day\n+40/day in march',
            ),
          ),
          const SizedBox(width: 12),
          _buildPercentBadge(),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '+380/day in march',
              style: TextStyle(fontSize: 9, color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentBadge() {
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_upward, color: Colors.white, size: 16),
          SizedBox(height: 2),
          Text(
            '15%',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}