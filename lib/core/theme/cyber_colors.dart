import 'package:flutter/material.dart';

/// Premium Commercial Cybersecurity Design System Palette
/// Inspired by Microsoft Defender, Google One, and enterprise security platforms.
class CyberColors {
  // Brand Foundation
  static const Color primary = Color(0xFF2563EB); // Primary enterprise blue
  static const Color primaryDark = Color(0xFF1E3A8A); // Dark navy blue
  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF60A5FA);
  static const Color primaryLight = Color(0xFFEFF6FF); // Soft blue background

  // Surface & Canvas (Light Enterprise Forensics Theme)
  static const Color background = Color(0xFFF5F7FA); // Main background: very light cool white
  static const Color surface = Color(0xFFFFFFFF); // Primary surface/cards: pure white
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBgSecondary = Color(0xFFF8FAFC); // Secondary surface
  static const Color cardBorder = Color(0xFFD9E0EA); // Subtle border
  static const Color cardBorderLight = Color(0xFFE5EBF2);
  static const Color glassBg = Color(0xFFFFFFFF); // Clean solid white card background
  static const Color glassBorder = Color(0xFFD9E0EA);

  // Status & Risk Levels
  static const Color success = Color(0xFF16A34A); // Success green
  static const Color warning = Color(0xFFD97706); // Warning amber
  static const Color danger = Color(0xFFDC2626); // Critical/Danger red
  static const Color riskSafe = Color(0xFF16A34A);
  static const Color riskWarning = Color(0xFFD97706);
  static const Color riskCritical = Color(0xFFDC2626);

  // Soft Tint Backgrounds & Borders
  static const Color softDangerBg = Color(0xFFFEF2F2); // Soft danger background
  static const Color softDangerBorder = Color(0xFFFECACA);
  static const Color softBlueBg = Color(0xFFEFF6FF); // Soft blue background
  static const Color softBlueBorder = Color(0xFFBFDBFE);
  static const Color softSuccessBg = Color(0xFFF0FDF4);
  static const Color softSuccessBorder = Color(0xFFBBF7D0);
  static const Color softWarningBg = Color(0xFFFFFBEB);
  static const Color softWarningBorder = Color(0xFFFDE68A);

  // Typography
  static const Color textPrimary = Color(0xFF172033); // Primary text: dark navy
  static const Color textSecondary = Color(0xFF5B6575); // Secondary text
  static const Color textMuted = Color(0xFF8896A6);
  static const Color textDark = Color(0xFF172033);
  static const Color textLight = Color(0xFFFFFFFF);

  // Enterprise Navy & Neutral Accents (Redirected from dark slate)
  static const Color darkBlue = Color(0xFF1E3A8A);
  static const Color darkBlueBg = Color(0xFFF5F7FA);
  static const Color darkBlueSurface = Color(0xFFFFFFFF); // Transformed from dark grey to pure white
  static const Color darkBlueBorder = Color(0xFFD9E0EA); // Transformed from dark slate to clean border

  // Accent Tones (Mapped to Enterprise Blue & Accents)
  static const Color neonCyan = Color(0xFF2563EB); // Enterprise blue
  static const Color neonPink = Color(0xFFDC2626); // Threat accent
  static const Color cyberPurple = Color(0xFF6366F1);
  static const Color cyberBlue = Color(0xFF2563EB);

  // Enterprise Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFFF5F7FA),
      Color(0xFFF8FAFC),
      Color(0xFFF5F7FA),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cyberMeshGradient = LinearGradient(
    colors: [
      Color(0xFFF5F7FA),
      Color(0xFFEFF6FF),
      Color(0xFFF5F7FA),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cyanGlowGradient = LinearGradient(
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF2563EB),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGlowGradient = LinearGradient(
    colors: [
      Color(0xFFEF4444),
      Color(0xFFDC2626),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBorderGradient = LinearGradient(
    colors: [
      Color(0xFFD9E0EA),
      Color(0xFFE5EBF2),
      Color(0xFFD9E0EA),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Emergency Red Palette
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color emergencyDarkRed = Color(0xFF991B1B);
  static const Color emergencyGlowRed = Color(0xFFEF4444);
  static const Color emergencySurface = Color(0xFFFEF2F2);
  static const Color emergencyBorder = Color(0xFFFECACA);

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [
      Color(0xFFDC2626),
      Color(0xFFB91C1C),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGlowGradient = LinearGradient(
    colors: [
      Color(0xFFEF4444),
      Color(0xFFDC2626),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Enterprise Clean Shadows: 0 4px 16px rgba(15, 23, 42, 0.06)
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F0F172A), // 0.06 opacity of #0F172A
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> primaryGlowShadow = [
    BoxShadow(
      color: Color(0x1F2563EB),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
