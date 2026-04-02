import 'package:flutter/material.dart';
import '../../colors/dashboard_colors.dart';
import '../../fonts/dashboard_text_styles.dart';

/// The full-width "Save Expense" button used at the bottom of AddExpensePage.
class DashboardSaveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const DashboardSaveButton({
    super.key,
    this.label = 'Save Expense',
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DashboardColors.cardBg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: DashboardColors.teal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(label, style: DashboardTextStyles.saveButtonLabel),
        ),
      ),
    );
  }
}
