import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppCardTheme {
  static CardThemeData get theme => CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.05),
      );
}