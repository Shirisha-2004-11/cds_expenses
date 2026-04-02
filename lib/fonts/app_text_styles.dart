import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'Poppins';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static const TextStyle buttonOutlined = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle buttonWhite = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMedium,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const TextStyle orDivider = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textMedium,
  );
}