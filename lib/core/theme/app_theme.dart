import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'neon_themes.dart';

class AppColors {
  // All driven by the active theme so non-dark palettes (normal_light) work.
  static Color get primary => currentTheme.primary;
  static Color get secondary => currentTheme.secondary;
  static Color get accent => currentTheme.accent;

  static Color get income => currentTheme.income;
  static Color get expense => currentTheme.expense;
  static Color get warning => currentTheme.warning;
  static Color get info => currentTheme.accent;

  static Color get background => currentTheme.background;
  static Color get surface => currentTheme.surface;
  static Color get surfaceLight => currentTheme.surfaceLight;
  static Color get card => currentTheme.card;

  static Color get textPrimary => currentTheme.textPrimary;
  static Color get textSecondary => currentTheme.textSecondary;
  static Color get textMuted => currentTheme.textMuted;

  // Global theme state holder (internal use)
  static NeonTheme currentTheme = NeonThemes.synthwave;

  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];

  static LinearGradient get neonGradient => LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Was const; now follows the active theme so light mode doesn't render on
  // a hardcoded dark gradient.
  static LinearGradient get spaceGradient {
    final isLight = currentTheme.brightness == Brightness.light;
    return LinearGradient(
      colors: [
        currentTheme.background,
        isLight ? currentTheme.surfaceLight : const Color(0xFF1A1A2E),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}

class AppTextStyles {
  static TextStyle get headlineMainframe => GoogleFonts.orbitron(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
  );

  static TextStyle get headlineTitle => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMain => GoogleFonts.inter(
    fontSize: 16,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get moneyLarge => GoogleFonts.orbitron(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelNeon => GoogleFonts.orbitron(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    color: AppColors.accent,
  );
}

class AppTheme {
  static ThemeData createTheme(NeonTheme neonTheme) {
    // Update the static holder for legacy code support
    AppColors.currentTheme = neonTheme;

    final isLight = neonTheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: neonTheme.brightness,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: isLight
          ? ColorScheme.light(
              primary: neonTheme.primary,
              secondary: neonTheme.accent,
              surface: AppColors.surface,
              error: neonTheme.expense,
            )
          : ColorScheme.dark(
              primary: neonTheme.primary,
              secondary: neonTheme.accent,
              surface: AppColors.surface,
              error: neonTheme.expense,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineTitle,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.surfaceLight, width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background.withValues(alpha: 0.8),
        selectedItemColor: neonTheme.accent,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background.withValues(alpha: 0.8),
        indicatorColor: neonTheme.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.labelNeon.copyWith(fontSize: 10),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: neonTheme.accent);
          }
          return IconThemeData(color: AppColors.textMuted);
        }),
      ),
    );
  }

  // Legacy support
  static ThemeData get darkTheme => createTheme(NeonThemes.synthwave);
}
