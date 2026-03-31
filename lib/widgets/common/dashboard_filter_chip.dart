import 'package:flutter/material.dart';
import '../../theme/dashboard_colors.dart';
import '../../theme/dashboard_text_styles.dart';

/// Animated pill-shaped filter chip used in Expenses_History and similar lists.
class DashboardFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DashboardFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? DashboardColors.tealAlt : DashboardColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? DashboardColors.tealAlt : DashboardColors.borderLight,
            width: 0.9,
          ),
        ),
        child: Text(
          label,
          style: isSelected
              ? DashboardTextStyles.filterChipLabelSelected
              : DashboardTextStyles.filterChipLabel,
        ),
      ),
    );
  }
}
