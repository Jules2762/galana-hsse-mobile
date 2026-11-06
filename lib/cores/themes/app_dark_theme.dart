import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_colors.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_bottom_navigation_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_button_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_card_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_checkbox_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_chip_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_input_theme.dart';
import 'package:gestion_hsse/cores/themes/widget_themes/app_snack_bar_theme.dart';
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
      surface: AppColors.darkSurface,
      error: AppColors.danger,
      onSurface: AppColors.darkTextPrimary,
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkSurface,
    cardTheme: AppCardTheme.darkTheme,
    inputDecorationTheme: AppInputTheme.darkTheme,
    navigationBarTheme: AppBottomNavigationTheme.darkTheme,
    dividerColor: AppColors.darkBorder,
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14,
        color: AppColors.darkTextSecondary,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      modalBackgroundColor: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme,
    outlinedButtonTheme: AppButtonTheme.outlinedButtonTheme,
    textButtonTheme: AppButtonTheme.textButtonTheme,
    textTheme: AppTextTheme.darkTheme,
    chipTheme: AppChipTheme.theme,
    snackBarTheme: AppSnackBarTheme.theme,
    checkboxTheme: AppCheckboxTheme.theme,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primaryDark,
      selectionHandleColor: AppColors.primary,
    ),
  );
}
