import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors (The Grid Palette)
  static const Color primary = Color(0xFF9D50BB); // Cyber Purple
  static const Color secondary = Color(0xFF6E48AA); // Deep Violet
  static const Color accent = Color(0xFF00F2FE); // Laser Cyan
  
  // Semantic Colors (Neon Indicators)
  static const Color income = Color(0xFF00FFB2); // Neon Mint
  static const Color expense = Color(0xFFFF0055); // Blood Neon Red
  static const Color warning = Color(0xFFFFD700); // Gold Glow
  static const Color info = Color(0xFF00F2FE); // Laser Cyan
  
  // Neutral Colors (Space Gradients)
  static const Color background = Color(0xFF0B0B15); // Deep Space
  static const Color surface = Color(0xFF161625); // Mainframe Surface
  static const Color surfaceLight = Color(0xFF212135); // Grid Lines
  static const Color card = Color(0xFF1C1C2E); // Module Surface
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B4C4);
  static const Color textMuted = Color(0xFF5A5A7A);
  
  // Glow / Effects
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x4D9D50BB),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];
  
  static const LinearGradient neonGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient spaceGradient = LinearGradient(
    colors: [background, Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTextStyles {
  // Use GoogleFonts for the Synthwave vibe
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
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.expense,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineTitle,
      ),
      cardTheme: CardTheme(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.surfaceLight, width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background.withOpacity(0.8),
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background.withOpacity(0.8),
        indicatorColor: AppColors.primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          AppTextStyles.labelNeon.copyWith(fontSize: 10),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent);
          }
          return const IconThemeData(color: AppColors.textMuted);
        }),
      ),
    );
  }
}
