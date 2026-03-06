import 'package:flutter/material.dart';

class ButtonStyles {
  // Shared Colors
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFA0A0A0);
  static const Color dangerBase = Color(0xFFFF3B30);
  static const Color successBase = Color(0xFF34C759);

  // Border & Corner Presets
  static const double radius = 14.0;
  static const double pillRadius = 100.0;
  static Border sideSubtle = Border.all(
    color: Colors.white.withOpacity(0.08),
    width: 1.0,
  );

  // Padding
  static const EdgeInsets paddingStandard = EdgeInsets.symmetric(
    vertical: 16.0,
    horizontal: 24.0,
  );
  
  static const EdgeInsets paddingSmall = EdgeInsets.symmetric(
    vertical: 10.0,
    horizontal: 16.0,
  );

  // Glow Shadows
  static List<BoxShadow> getGlow(Color color) {
    return [
      // Hard drop shadow
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
      // Colored glow
      BoxShadow(
        color: color.withOpacity(0.3),
        blurRadius: 20,
        spreadRadius: 2,
        offset: const Offset(0, 8),
      ),
    ];
  }

  // Inner shadow logic for toggles
  static List<BoxShadow> innerShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}
