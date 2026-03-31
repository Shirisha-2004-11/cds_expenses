import 'package:flutter/material.dart';
import '../../theme/dashboard_text_styles.dart';

/// A muted section-label text widget used in AddExpensePage
/// (e.g. "Category", "Payment Method", "Merchant").
class DashboardSectionLabel extends StatelessWidget {
  final String text;

  const DashboardSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: DashboardTextStyles.sectionLabel);
  }
}
