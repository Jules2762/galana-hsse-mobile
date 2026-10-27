import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_bar_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_bottom_navigation_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_button_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_card_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_checkbox_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_chip_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_input_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_snack_bar_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_text_theme.dart';


class AppLightTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.lightBackground,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.info,
      tertiary: AppColors.training,
      surface: AppColors.lightSurface,
      error: AppColors.danger,
    ),

    cardTheme: AppCardTheme.theme,
    appBarTheme: AppAppBarTheme.theme,
    inputDecorationTheme: AppInputTheme.theme,
    textTheme: AppTextTheme.theme,
    elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme,
    outlinedButtonTheme: AppButtonTheme.outlinedButtonTheme,
    chipTheme: AppChipTheme.theme,
    snackBarTheme: AppSnackBarTheme.theme,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primaryLight,
      selectionHandleColor: AppColors.primary,
    ),
    navigationBarTheme: AppBottomNavigationTheme.theme,
    checkboxTheme: AppCheckboxTheme.theme,
  );
}
