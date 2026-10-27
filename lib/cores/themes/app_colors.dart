import 'package:flutter/material.dart';


class AppColors {
  // =========================
  // GALANA BRAND COLORS
  // =========================

  /// Couleur principale GALANA
  static const primary = Color(0xFF0F9D58);

  /// Vert foncé utilisé pour gradients et états actifs
  static const primaryDark = Color(0xFF087443);

  /// Vert clair pour les backgrounds positifs
  static const primaryLight = Color(0xFFE8F5EE);

  /// Accent couleur secondaire
  static const accent = Color(0xFF14B86A);

  // =========================
  // STATUS COLORS
  // =========================

  /// Succès
  static const success = Color(0xFF22C55E);
  static const successBg = Color(0xFFDCFCE7);

  /// Information
  static const info = Color(0xFF3B82F6);
  static const infoBg = Color(0xFFDBEAFE);

  /// Attention
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFEF3C7);

  /// Erreur / Non-conformité
  static const danger = Color(0xFFEF4444);
  static const dangerBg = Color(0xFFFEE2E2);

  /// Critique
  static const critical = Color(0xFFDC2626);
  static const criticalBg = Color(0xFFFECACA);

  // =========================
  // TRAINING MODULE
  // =========================

  static const training = Color(0xFFF59E0B);
  static const trainingBg = Color(0xFFFEF3C7);

  // =========================
  // LIGHT THEME
  // =========================

  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);

  // =========================
  // DARK THEME
  // =========================

  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);

  // =========================
  // TEXT COLORS
  // =========================

  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textDisabled = Color(0xFF94A3B8);

  // =========================
  // BORDERS
  // =========================

  static const border = Color(0xFFE2E8F0);

  // =========================
  // DASHBOARD COLORS
  // =========================

  static const inspection = Color(0xFF3B82F6);
  static const inspectionBg = Color(0xFFDBEAFE);

  static const action = Color(0xFF22C55E);
  static const actionBg = Color(0xFFDCFCE7);

  static const alert = Color(0xFFEF4444);
  static const alertBg = Color(0xFFFEE2E2);

  // =========================
  // GRADIENTS
  // =========================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF0F9D58),
      Color(0xFF087443),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dashboardGradient = LinearGradient(
    colors: [
      Color(0xFF0F9D58),
      Color(0xFF14B86A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
