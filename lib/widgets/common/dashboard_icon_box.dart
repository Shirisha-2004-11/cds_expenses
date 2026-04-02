import 'package:flutter/material.dart';
// ignore: unused_import
import '../../colors/dashboard_colors.dart';

/// A small rounded icon container used for expense category icons,
/// notification bell, stat percent badge, etc.
class DashboardIconBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;
  final double borderRadius;
  final BoxShape shape;

  const DashboardIconBox({
    super.key,
    required this.child,
    required this.color,
    this.size = 40,
    this.borderRadius = 10,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        shape: shape,
      ),
      child: child,
    );
  }
}
