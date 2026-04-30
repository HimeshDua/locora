import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: Color(0xFF0EA5A4),
      primaryContainer: Color(0xFFCCFBF1),
      secondary: Color(0xFF4F46E5),
      secondaryContainer: Color(0xFFE0E7FF),
      tertiary: Color(0xFFF59E0B),
      tertiaryContainer: Color(0xFFFEF3C7),
      appBarColor: Color(0xFFE0E7FF),
      error: Color(0xFFDC2626),
      errorContainer: Color(0xFFFEE2E2),
    ),
    subThemesData: const FlexSubThemesData(
      inputDecoratorIsFilled: true,
      alignedDropdown: true,
      tooltipRadius: 4,
      tooltipSchemeColor: SchemeColor.inverseSurface,
      tooltipOpacity: 0.9,
      snackBarElevation: 6,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
      navigationRailUseIndicator: true,
    ),
    keyColors: const FlexKeyColors(),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    fontFamily: 'Inter',

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(fontFamily: 'Inter'),
      labelLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
    ),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    // User defined custom colors made with FlexSchemeColor() API.
    colors: const FlexSchemeColor(
      primary: Color(0xFF0EA5A4),
      primaryContainer: Color(0xFFCCFBF1),
      primaryLightRef: Color(0xFF0EA5A4), // The color of light mode primary
      secondary: Color(0xFF4F46E5),
      secondaryContainer: Color(0xFFE0E7FF),
      secondaryLightRef: Color(0xFF4F46E5), // The color of light mode secondary
      tertiary: Color(0xFFF59E0B),
      tertiaryContainer: Color(0xFFFEF3C7),
      tertiaryLightRef: Color(0xFFF59E0B), // The color of light mode tertiary
      appBarColor: Color(0xFFE0E7FF),
      error: Color(0xFFDC2626),
      errorContainer: Color(0xFFFEE2E2),
    ),
    // Component theme configurations for dark mode.
    subThemesData: const FlexSubThemesData(
      blendOnColors: true,
      inputDecoratorIsFilled: true,
      alignedDropdown: true,
      tooltipRadius: 4,
      tooltipSchemeColor: SchemeColor.inverseSurface,
      tooltipOpacity: 0.9,
      snackBarElevation: 6,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
      navigationRailUseIndicator: true,
    ),
    // ColorScheme seed configuration setup for dark mode.
    keyColors: const FlexKeyColors(),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    fontFamily: 'Inter',

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(fontFamily: 'Inter'),
      labelLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
    ),
  );
}
