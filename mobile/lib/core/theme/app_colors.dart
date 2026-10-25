import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFFE2591B);
  static const Color primaryDark = Color(0xFFBE3E0A);
  static const Color primaryLight = Color(0xFFF97316);

  // Gradient for Operator Card & Banners
  static const LinearGradient operatorCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE5581A),
      Color(0xFFA83808),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFA7826),
      Color(0xFFE65100),
    ],
  );

  // Gradient for Operator Greeting Banner (left to right)
  static const LinearGradient operatorGreetingGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFA5390C),
      Color(0xFFEA580C),
    ],
  );

  // Navigation & Accent Colors
  static const Color operatorNavActive = Color(0xFFBE532B);
  static const Color operatorAccentRust = Color(0xFFBE3E0A);
  static const Color alertBadgeDark = Color(0xFF8B2508);

  // Background & Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF9FAFB);

  // Input & Dashboard card surfaces (soft lavender-blue tint from design)
  static const Color inputBackground = Color(0xFFEBF1FE);
  static const Color cardSoftBlue = Color(0xFFEDF2FE);

  // Badge colors
  static const Color badgeBackground = Color(0xFFECE6DF);
  static const Color badgeText = Color(0xFF3E3630);

  // Text colors
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textPlaceholder = Color(0xFF8F9CAE);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhiteMuted = Color(0xFFF3ECE6);
  static const Color buttonTextDark = Color(0xFF181513);

  // Alert & Status colors
  static const Color alertBadge = Color(0xFFB91C1C);
  static const Color alertBackground = Color(0xFFEFF4FF);
  static const Color alertWarning = Color(0xFFC2410C);
  static const Color statusOptimal = Color(0xFFE05315);
  static const Color statusGreen = Color(0xFF16A34A);
}
