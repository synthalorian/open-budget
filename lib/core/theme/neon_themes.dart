import 'package:flutter/material.dart';

class NeonTheme {
  final String name;
  final String displayName;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color income;
  final Color expense;
  final Color warning;
  final String unlockRank;
  final String description;

  // Surface palette — defaults preserve the original neon-dark backdrop so
  // existing themes work unchanged. Light themes override these.
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const NeonTheme({
    required this.name,
    required this.displayName,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.income,
    required this.expense,
    required this.warning,
    required this.unlockRank,
    required this.description,
    this.brightness = Brightness.dark,
    this.background = const Color(0xFF0B0B15),
    this.surface = const Color(0xFF161625),
    this.surfaceLight = const Color(0xFF212135),
    this.card = const Color(0xFF1C1C2E),
    this.textPrimary = const Color(0xFFFFFFFF),
    this.textSecondary = const Color(0xFFB4B4C4),
    this.textMuted = const Color(0xFF5A5A7A),
  });
}

class NeonThemes {
  static const NeonTheme synthwave = NeonTheme(
    name: 'synthwave',
    displayName: 'SYNTHWAVE',
    primary: Color(0xFF9D50BB),
    secondary: Color(0xFF6E48AA),
    accent: Color(0xFF00F2FE),
    income: Color(0xFF00FFB2),
    expense: Color(0xFFFF0055),
    warning: Color(0xFFFFD700),
    unlockRank: 'NEW_USER',
    description: 'The classic neon grid aesthetic',
  );

  static const NeonTheme outrun = NeonTheme(
    name: 'outrun',
    displayName: 'OUTRUN_SUNSET',
    primary: Color(0xFFFF6B6B),
    secondary: Color(0xFFFF8E53),
    accent: Color(0xFFFFFF66),
    income: Color(0xFF4ECDC4),
    expense: Color(0xFFFF1744),
    warning: Color(0xFFFFAB40),
    unlockRank: 'GRID_RUNNER',
    description: 'Chrome and sunsets, the original 80s vibe',
  );

  static const NeonTheme matrix = NeonTheme(
    name: 'matrix',
    displayName: 'MATRIX_GREEN',
    primary: Color(0xFF00FF41),
    secondary: Color(0xFF008F11),
    accent: Color(0xFF003B00),
    income: Color(0xFF00FF41),
    expense: Color(0xFFFF0000),
    warning: Color(0xFFFFFF00),
    unlockRank: 'GRID_RUNNER',
    description: 'Follow the white rabbit into the code',
  );

  static const NeonTheme cyberpunk = NeonTheme(
    name: 'cyberpunk',
    displayName: 'CYBERPUNK_YELLOW',
    primary: Color(0xFFFCEE0A),
    secondary: Color(0xFFFF2A6D),
    accent: Color(0xFF05D9E8),
    income: Color(0xFF00F0FF),
    expense: Color(0xFFFF003C),
    warning: Color(0xFFFFD300),
    unlockRank: 'MAINFRAME_MASTER',
    description: 'High tech, low life, maximum neon',
  );

  static const NeonTheme midnight = NeonTheme(
    name: 'midnight',
    displayName: 'MIDNIGHT_PURPLE',
    primary: Color(0xFF4A148C),
    secondary: Color(0xFF6A1B9A),
    accent: Color(0xFF7C4DFF),
    income: Color(0xFF69F0AE),
    expense: Color(0xFFFF5252),
    warning: Color(0xFFE040FB),
    unlockRank: 'MAINFRAME_MASTER',
    description: 'Deep purple shadows and ethereal glow',
  );

  static const NeonTheme vaporwave = NeonTheme(
    name: 'vaporwave',
    displayName: 'VAPORWAVE_PINK',
    primary: Color(0xFFFF71CE),
    secondary: Color(0xFFB967FF),
    accent: Color(0xFF01CDFE),
    income: Color(0xFF05FFA1),
    expense: Color(0xFFFF0097),
    warning: Color(0xFFFFF4F0),
    unlockRank: 'THE_ARCHITECT',
    description: 'A e s t h e t i c dreams in pink and cyan',
  );

  // Plain Material dark — quiet palette, no neon glow vibes
  static const NeonTheme normalDark = NeonTheme(
    name: 'normal_dark',
    displayName: 'NORMAL_DARK',
    primary: Color(0xFF6366F1),
    secondary: Color(0xFF818CF8),
    accent: Color(0xFF38BDF8),
    income: Color(0xFF10B981),
    expense: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    unlockRank: 'NEW_USER',
    description: 'Standard dark — no neon, just clean',
    background: Color(0xFF0F1115),
    surface: Color(0xFF181B22),
    surfaceLight: Color(0xFF222630),
    card: Color(0xFF1B1F27),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFFCBD5E1),
    textMuted: Color(0xFF64748B),
  );

  // Plain Material light — daytime mode, white backdrop
  static const NeonTheme normalLight = NeonTheme(
    name: 'normal_light',
    displayName: 'NORMAL_LIGHT',
    primary: Color(0xFF4F46E5),
    secondary: Color(0xFF6366F1),
    accent: Color(0xFF0EA5E9),
    income: Color(0xFF059669),
    expense: Color(0xFFDC2626),
    warning: Color(0xFFD97706),
    unlockRank: 'NEW_USER',
    description: 'Standard light — daytime mode',
    brightness: Brightness.light,
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFEEF1F6),
    card: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF334155),
    textMuted: Color(0xFF94A3B8),
  );

  static const List<NeonTheme> all = [
    synthwave,
    outrun,
    matrix,
    cyberpunk,
    midnight,
    vaporwave,
    normalDark,
    normalLight,
  ];

  static NeonTheme byName(String name) {
    return all.firstWhere(
      (t) => t.name == name,
      orElse: () => synthwave,
    );
  }
}
