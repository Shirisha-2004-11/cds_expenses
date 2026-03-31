import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_strings.dart';

class MicrosoftButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const MicrosoftButton({
    super.key,
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
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textDark,
          elevation: 4,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MicrosoftLogo(),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.continueWithMicrosoft,
                    style: AppTextStyles.buttonWhite,
                  ),
                ],
              ),
      ),
    );
  }
}

// Microsoft logo built with Flutter — no image asset needed
class _MicrosoftLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, color: const Color(0xFFF25022)),
              const SizedBox(width: 2),
              Container(width: 10, height: 10, color: const Color(0xFF7FBA00)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(width: 10, height: 10, color: const Color(0xFF00A4EF)),
              const SizedBox(width: 2),
              Container(width: 10, height: 10, color: const Color(0xFFFFB900)),
            ],
          ),
        ],
      ),
    );
  }
}