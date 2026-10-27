import 'package:flutter/material.dart';

class AppChipTheme {
  static ChipThemeData get theme => ChipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        shape: StadiumBorder(),
      );
}