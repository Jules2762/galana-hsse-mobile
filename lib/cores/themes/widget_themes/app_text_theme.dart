import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppTextTheme {
  static TextTheme get theme => const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),

        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),

        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),

        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textDisabled,
        ),
      );

  static TextTheme get darkTheme => const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),

        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),

        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),

        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),

        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),

        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),

        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.darkTextPrimary,
        ),

        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.darkTextSecondary,
        ),

        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.darkTextDisabled,
        ),
      );
}