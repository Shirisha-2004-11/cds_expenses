import 'package:flutter/material.dart';
import '../../colors/app_colors.dart';
import '../../fonts/app_text_styles.dart';

class OutlinedPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const OutlinedPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 59,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: 4,
          shadowColor: AppColors.shadow,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              )
            : Text(label, style: AppTextStyles.buttonOutlined),
      ),
    );
  }
}