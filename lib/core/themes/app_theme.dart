// lib/core/themes/app_theme.dart
// Thal-Care Diagnostic App - Professional Color System
// Supports: Light Theme + Dark Theme

import 'package:flutter/material.dart';

class AppColors {
  // ==================== PRIMARY COLOR SYSTEM ====================
  static const Color primaryGreen = Color(0xFF059669);
  static const Color primaryDark = Color(0xFF065f46);
  static const Color primaryMid = Color(0xFF047857);
  static const Color primaryLight = Color(0xFF6ee7b7);
  static const Color primaryExtraLight = Color(0xFFdcfce7);

  // ==================== SECONDARY COLORS ====================
  static const Color secondaryBlue = Color(0xFF2563eb);
  static const Color secondaryPurple = Color(0xFF9333ea);
  static const Color secondaryOrange = Color(0xFFd97706);
  static const Color secondaryRed = Color(0xFFdc2626);

  // ==================== BACKGROUND COLORS ====================
  static const Color backgroundLight = Color(0xFFf7f8fc);
  static const Color backgroundDark = Color(0xFF0f172a);
  static const Color surfaceLight = Color(0xFFffffff);
  static const Color surfaceDark = Color(0xFF1e293b);

  // ==================== TEXT COLORS ====================
  static const Color textDark = Color(0xFF0f172a);
  static const Color textGray = Color(0xFF64748b);
  static const Color textLightGray = Color(0xFF94a3b8);
  static const Color textWhite = Color(0xFFffffff);
  static const Color textSoftWhite = Color(0xFFf1f5f9);

  // ==================== BORDER COLORS ====================
  static const Color borderLight = Color(0xFFe8eaf0);
  static const Color borderDark = Color(0xFF334155);

  // ==================== STATUS COLORS ====================
  static const Color success = Color(0xFF10b981);
  static const Color warning = Color(0xFFf59e0b);
  static const Color error = Color(0xFFef4444);
  static const Color info = Color(0xFF3b82f6);

  // ==================== CATEGORY BACKGROUNDS ====================
  static const Color bloodWorkBg = Color(0xFFfef2f2);
  static const Color diabetesBg = Color(0xFFeff6ff);
  static const Color renalBg = Color(0xFFf0fdf4);
  static const Color hepaticBg = Color(0xFFfffbeb);
  static const Color cardioBg = Color(0xFFfdf4ff);

  // ==================== CATEGORY COLORS ====================
  static const Color bloodWorkColor = Color(0xFFdc2626);
  static const Color diabetesColor = Color(0xFF2563eb);
  static const Color renalColor = Color(0xFF16a34a);
  static const Color hepaticColor = Color(0xFFd97706);
  static const Color cardioColor = Color(0xFF9333ea);

  // ==================== SHADOWS ====================
  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.grey.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.grey.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryGreen.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

class AppTheme {
  // ==================== LIGHT THEME ====================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Primary Colors
    primaryColor: AppColors.primaryGreen,
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGreen,
      secondary: AppColors.primaryGreen,
      tertiary: AppColors.primaryLight,
      background: AppColors.backgroundLight,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
    ),

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.backgroundLight,

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      iconTheme: IconThemeData(color: AppColors.textDark),
    ),

    // Text Theme
    textTheme: const TextTheme(
      // Headings
      headlineLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),

      // Body Text
      bodyLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      bodySmall: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textGray,
      ),

      // Labels
      labelLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      labelMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textGray,
      ),
      labelSmall: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textLightGray,
      ),

      // Title
      titleLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleSmall: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textGray,
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.borderLight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        textStyle: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        color: AppColors.textLightGray,
      ),
      labelStyle: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        color: AppColors.textGray,
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 0.5,
      space: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundLight,
      labelStyle: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: AppColors.borderLight),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textLightGray,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  // ==================== DARK THEME ====================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Primary Colors
    primaryColor: AppColors.primaryGreen,
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryGreen,
      secondary: AppColors.primaryGreen,
      tertiary: AppColors.primaryLight,
      background: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
    ),

    // Scaffold Background
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textWhite,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      iconTheme: IconThemeData(color: AppColors.textWhite),
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSoftWhite,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSoftWhite,
      ),
      bodySmall: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textLightGray,
      ),
      labelLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      labelMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textLightGray,
      ),
      titleLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
      titleMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      ),
    ),

    // Card Theme (Dark)
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),

    // Input Decoration (Dark)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        color: AppColors.textLightGray,
      ),
    ),

    // Divider (Dark)
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 0.5,
    ),

    // Bottom Navigation Bar (Dark)
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textLightGray,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

// ==================== SPACING CONSTANTS ====================
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const EdgeInsets paddingScreen = EdgeInsets.all(16.0);
  static const EdgeInsets paddingCard = EdgeInsets.all(14.0);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
}

// ==================== BORDER RADIUS CONSTANTS ====================
class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 14.0;
  static const double xl = 16.0;
  static const double circle = 100.0;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
}

// ==================== TYPOGRAPHY HELPERS ====================
class AppTypography {
  static const String fontFamily = 'DM Sans';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
}
