import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors (Inspired by Mascot Palette in image.png)
  static const Color primary = Color(0xFFFED22A); // Sunflower Golden Yellow (#FED22A)
  static const Color primaryDark = Color(0xFF262626); // Deep Charcoal / Mascot Outline (#262626)
  static const Color primaryLight = Color(0xFFFEF08A); // Soft Yellow 200 (#FEF08A)
  static const Color primaryContainer = Color(0xFFFFF8D6); // Warm Butter Cream Container (#FFF8D6)
  static const Color onPrimary = Color(0xFF1E1E1E); // Contrast text & icon on yellow button (#1E1E1E)
  static const Color accentAmber = Color(0xFFD97706); // Warm Amber Gold
  static const Color darkPrimaryContainer = Color(0xFF3D320B); // Dark Warm Amber Container

  // Status Colors (Balanced with Warm Character Theme)
  static const Color success = Color(0xFF10B981); // Emerald Green 500
  static const Color successLight = Color(0xFFD1FAE5); // Green 100
  static const Color successDark = Color(0xFF047857);

  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7); // Amber 100
  static const Color warningDark = Color(0xFFB45309);

  static const Color danger = Color(0xFFEF4444); // Red 500
  static const Color dangerLight = Color(0xFFFEE2E2); // Red 100
  static const Color dangerDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF3B82F6); // Blue 500
  static const Color infoLight = Color(0xFFDBEAFE); // Blue 100

  // Neutral Light (Warm, friendly, clean)
  static const Color background = Color(0xFFFAF9F6); // Soft Warm Off-White
  static const Color surface = Color(0xFFFFFFFF); // Mascot White Body
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121); // Charcoal Black
  static const Color textSecondary = Color(0xFF6B6A66); // Warm Neutral Gray
  static const Color textTertiary = Color(0xFFA3A29D); // Muted Stone Gray
  static const Color textPlaceholder = Color(0xFFB8B7B2); // Faded soft placeholder for light mode
  static const Color border = Color(0xFFEBE6DC); // Warm Soft Border
  static const Color divider = Color(0xFFF3EFE6);

  // Neutral Dark (Deep Warm Charcoal & Carbon Black)
  static const Color darkBackground = Color(0xFF18181A); // Deep Warm Charcoal
  static const Color darkSurface = Color(0xFF242426); // Mascot Charcoal Surface
  static const Color darkSurfaceElevated = Color(0xFF333333); // Mascot Dark Outline Tone (#333333)
  static const Color darkTextPrimary = Color(0xFFFAFAFA); // Crisp Mascot Body White
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // Neutral Muted Gray
  static const Color darkTextPlaceholder = Color(0xFF6B6B74); // Faded soft placeholder for dark mode
  static const Color darkBorder = Color(0xFF38383D); // Subtle Dark Border

  // Card & Badge Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFDD4B), Color(0xFFFED22A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF9F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
