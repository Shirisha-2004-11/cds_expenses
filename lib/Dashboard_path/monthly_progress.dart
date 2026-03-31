import 'package:flutter/material.dart';
// ── Centralised theme tokens ─────────────────────────────────────────────────
// ignore: unused_import
import '../theme/dashboard_colors.dart';
// ignore: unused_import
import '../theme/dashboard_text_styles.dart';
// ignore: unused_import
import '../widgets/common/dashboard_card.dart';

class BudgetProgressCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;

  const BudgetProgressCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalSpent / totalBudget;
    final double remaining = totalBudget - totalSpent;

    Color progressColor;
    String statusText;

    if (progress < 0.6) {
      progressColor = const Color(0xFF4CAF50);
      statusText = 'On track 🎯';
    } else if (progress < 0.85) {
      progressColor = const Color(0xFFFFB347);
      statusText = 'Spending up ⚠️';
    } else {
      progressColor = const Color(0xFFE53935);
      statusText = 'Near limit 🔴';
    }

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
          // Title + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Budget',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          const SizedBox(height: 10),

          // Spent + Remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spent',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    '₹ ${totalSpent.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Remaining',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    '₹ ${remaining.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Percentage label
          Center(
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}% of ₹ ${totalBudget.toStringAsFixed(0)} used',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}