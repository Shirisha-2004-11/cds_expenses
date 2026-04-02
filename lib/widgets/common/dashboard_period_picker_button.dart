import 'package:flutter/material.dart';
import '../../colors/dashboard_colors.dart';
import '../../fonts/dashboard_text_styles.dart';

/// Small pill button showing the currently selected period (e.g. "Last 30 days")
/// with a dropdown arrow — used in both MonthlyAnalyticsCard and Expenses_History.
class DashboardPeriodPickerButton extends StatelessWidget {
  final String selectedPeriod;
  final VoidCallback onTap;

  const DashboardPeriodPickerButton({
    super.key,
    required this.selectedPeriod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: DashboardColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DashboardColors.borderLight, width: 0.9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedPeriod, style: DashboardTextStyles.historyPeriodText),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFF3C3C3E),
            ),
          ],
        ),
      ),
    );
  }
}
