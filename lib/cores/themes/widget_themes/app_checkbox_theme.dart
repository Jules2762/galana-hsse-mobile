import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppCheckboxTheme {
  static CheckboxThemeData get theme => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.white;
          },
        ),

        checkColor: WidgetStateProperty.all(
          Colors.white,
        ),

        side: const BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      );
}