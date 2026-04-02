import 'package:flutter/material.dart';
import '../../colors/dashboard_colors.dart';
// ignore: unused_import
import '../../fonts/dashboard_text_styles.dart';

/// A bordered, rounded text input field used across Dashboard screens
/// (date, note, merchant etc.).
class DashboardTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const DashboardTextField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: DashboardColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.chipBorder, width: 0.8),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: DashboardColors.textDark2,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: DashboardColors.textHint,
            fontSize: 14,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
