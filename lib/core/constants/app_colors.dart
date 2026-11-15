import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF2563EB); // Vibrant Blue
  static const Color primaryDark = Color(0xFF1E3A8A); // Navy
  static const Color primaryLight = Color(0xFFDBEAFE); // Soft Blue 100
  static const Color primaryContainer = Color(0xFFEFF6FF); // Blue 50

  // Status Colors
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successLight = Color(0xFFDCFCE7); // Green 100
  static const Color successDark = Color(0xFF15803D);

  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7); // Amber 100
  static const Color warningDark = Color(0xFFD97706);

  static const Color danger = Color(0xFFEF4444); // Red 500
  static const Color dangerLight = Color(0xFFFEE2E2); // Red 100
  static const Color dangerDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF0EA5E9); // Sky 500
  static const Color infoLight = Color(0xFFE0F2FE); // Sky 100

  // Neutral Light
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // Neutral Dark
  static const Color darkBackground = Color(0xFF0B1329);
  static const Color darkSurface = Color(0xFF131E3A);
  static const Color darkSurfaceElevated = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // Card & Badge Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
