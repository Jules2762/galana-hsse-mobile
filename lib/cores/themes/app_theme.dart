import 'package:flutter/material.dart';
import 'package:gestion_hsse/cores/themes/app_dark_theme.dart';
import 'package:gestion_hsse/cores/themes/app_light_theme.dart';

class AppTheme {
  static ThemeData get light=>AppLightTheme.theme;
  static ThemeData get dark=>AppDarkTheme.theme;
}