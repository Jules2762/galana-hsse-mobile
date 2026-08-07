import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppSnackBarTheme {
  static SnackBarThemeData get theme => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
}