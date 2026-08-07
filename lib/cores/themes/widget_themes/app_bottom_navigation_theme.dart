import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppBottomNavigationTheme {
  static NavigationBarThemeData get theme =>
      NavigationBarThemeData(
        height: 72,

        backgroundColor: AppColors.lightSurface,

        elevation: 0,

        // Supprime la capsule bleue
        indicatorColor: Colors.transparent,

        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,

        labelTextStyle:
            WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            return TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textSecondary,
            );
          },
        ),

        iconTheme:
            WidgetStateProperty.resolveWith<IconThemeData>(
          (states) {
            return IconThemeData(
              size: 26,
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.textSecondary,
            );
          },
        ),
      );
}