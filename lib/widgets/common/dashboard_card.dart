import 'package:flutter/material.dart';
import '../../colors/dashboard_colors.dart';

/// A generic rounded white card used throughout the Dashboard screens.
/// Wraps [child] with consistent padding, border-radius and drop-shadow.
class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;

  const DashboardCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? DashboardColors.cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
