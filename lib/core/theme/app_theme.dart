import 'package:flutter/material.dart';

/// ==========================================================
/// Athkar Design System — generated from Stitch DESIGN.md
/// Deep Teal + Warm Gold, serene minimalist Islamic UI
/// Light & Dark (Midnight OLED) Themes
/// ==========================================================

class AppColors {
  AppColors._();

  // Surfaces (Light)
  static const surface = Color(0xFFFBF9F1);
  static const surfaceDim = Color(0xFFDCDAD2);
  static const surfaceBright = Color(0xFFFBF9F1);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF5F4EC);
  static const surfaceContainer = Color(0xFFF0EEE6);
  static const surfaceContainerHigh = Color(0xFFEAE8E0);
  static const surfaceContainerHighest = Color(0xFFE4E3DB);

  static const onSurface = Color(0xFF1B1C17);
  static const onSurfaceVariant = Color(0xFF3F4945);
  static const inverseSurface = Color(0xFF30312C);
  static const inverseOnSurface = Color(0xFFF3F1E9);

  static const outline = Color(0xFF707975);
  static const outlineVariant = Color(0xFFBFC9C4);
  static const surfaceTint = Color(0xFF29695B);

  // Primary — Deep Teal
  static const primary = Color(0xFF00342B);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF004D40);
  static const onPrimaryContainer = Color(0xFF7EBDAC);
  static const inversePrimary = Color(0xFF94D3C1);

  // Secondary — Warm Gold
  static const secondary = Color(0xFF775A19);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFED488);
  static const onSecondaryContainer = Color(0xFF785A1A);

  // Tertiary
  static const tertiary = Color(0xFF253028);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF3B463E);
  static const onTertiaryContainer = Color(0xFFA7B4A9);

  // Functional
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Fixed tones
  static const primaryFixed = Color(0xFFAFEFDD);
  static const primaryFixedDim = Color(0xFF94D3C1);
  static const onPrimaryFixed = Color(0xFF00201A);
  static const secondaryFixed = Color(0xFFFFDEA1);
  static const secondaryFixedDim = Color(0xFFFED488);
  static const onSecondaryFixed = Color(0xFF261900);

  // Elevation & Layering
  static const background = surface;
  static const level1Card = surfaceContainerLowest;
  static const level2Modal = surfaceContainerLow;
  static const level3Accent = primaryFixedDim;
}

class AppColorsDark {
  AppColorsDark._();

  // Midnight OLED Palette
  static const background = Color(0xFF091210);
  static const surface = Color(0xFF0D1714);
  static const surfaceContainerLowest = Color(0xFF060D0B);
  static const surfaceContainerLow = Color(0xFF0F1C18);
  static const surfaceContainer = Color(0xFF13221E);
  static const surfaceContainerHigh = Color(0xFF172924);
  static const surfaceContainerHighest = Color(0xFF1C312B);

  static const level1Card = Color(0xFF12201C);
  static const level2Modal = Color(0xFF162722);
  static const level3Accent = Color(0xFF1E3831);

  static const onSurface = Color(0xFFE8F2EE);
  static const onSurfaceVariant = Color(0xFFA2B5AF);

  // High Contrast Primary & Secondary for Dark Theme
  static const primary = Color(0xFF7EBDAC);
  static const onPrimary = Color(0xFF00382E);
  static const primaryContainer = Color(0xFF004D40);
  static const onPrimaryContainer = Color(0xFFAFEFDD);

  static const secondary = Color(0xFFFED488);
  static const onSecondary = Color(0xFF422E00);
  static const secondaryContainer = Color(0xFF5D4200);
  static const onSecondaryContainer = Color(0xFFFFDEA1);

  static const outline = Color(0xFF425650);
  static const outlineVariant = Color(0xFF263833);
}

class AppShadows {
  AppShadows._();

  static const sublte = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const liftedPaper = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const glowGold = [
    BoxShadow(
      color: Color(0x33FED488),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];

  static const glowTeal = [
    BoxShadow(
      color: Color(0x3329695B),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];
}

class AppSpacing {
  AppSpacing._();

  static const double base = 8;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double containerMargin = 20;
}

class AppRadius {
  AppRadius._();

  static const double sm = 4;
  static const double base = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;
}

class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color baseColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 52 / 40,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: baseColor,
      ),
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme(AppColors.onSurface),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.level1Card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.full)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColorsDark.primary,
      onPrimary: AppColorsDark.onPrimary,
      primaryContainer: AppColorsDark.primaryContainer,
      onPrimaryContainer: AppColorsDark.onPrimaryContainer,
      secondary: AppColorsDark.secondary,
      onSecondary: AppColorsDark.onSecondary,
      secondaryContainer: AppColorsDark.secondaryContainer,
      onSecondaryContainer: AppColorsDark.onSecondaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColorsDark.surface,
      onSurface: AppColorsDark.onSurface,
      surfaceContainerHighest: AppColorsDark.surfaceContainerHighest,
      onSurfaceVariant: AppColorsDark.onSurfaceVariant,
      outline: AppColorsDark.outline,
      outlineVariant: AppColorsDark.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColorsDark.background,
      textTheme: AppTypography.textTheme(AppColorsDark.onSurface),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorsDark.surface,
        foregroundColor: AppColorsDark.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColorsDark.onSurface,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColorsDark.level1Card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.primary,
          foregroundColor: AppColorsDark.onPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.full)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
