import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_button_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_text_theme.dart';

class AppDarkTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
  primary: AppColors.primary,
  secondary: AppColors.info,
  tertiary: AppColors.training,
  surface: AppColors.lightSurface,
  error: AppColors.danger,
),
    scaffoldBackgroundColor: AppColors.darkBackground,
    elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        foregroundColor: Colors.white,
      ),
    ),
    textTheme: AppTextTheme.theme,
  );
  
}
