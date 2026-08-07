import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppAppBarTheme {
  static AppBarTheme get theme => const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      );
}