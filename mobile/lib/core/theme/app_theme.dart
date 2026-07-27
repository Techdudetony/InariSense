/// Main app theme, assembled from docs/07-design-system.md's tokens.
///
/// Typography note: the design doc calls for a humanist sans for
/// headings and a legible sans for body text (e.g. Nunito/Work Sans +
/// Inter). This is deliberately NOT implemented via the google_fonts
/// package here — that package fetches font files over the network at
/// runtime by default, which risks breaking first-run behavior for a
/// user who opens the app offline (a real MVP requirement). This uses
/// the platform default font (Roboto/San Francisco) with the design
/// system's size/weight scale instead. Custom bundled fonts (shipped as
/// app assets, not fetched at runtime) are a reasonable later polish
/// step, not something dropped by accident.
library;

import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.canopy,
    primary: AppColors.canopy,
    secondary: AppColors.sprout,
    error: AppColors.error,
    surface: AppColors.paper,
  );

  const textTheme = TextTheme(
    // Display: screen titles — 28sp per the design system's type scale.
    headlineLarge: TextStyle(
        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.ink),
    // Heading: section titles — 20sp
    titleLarge: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
    // Body — 16sp
    bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.ink),
    bodyMedium: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.ink),
    // Caption/meta (sources, timestamps) — 13sp, never smaller anywhere
    // in the app per the dynamic-text-sizing accessibility requirement.
    bodySmall: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.soil),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.paper,
    textTheme: textTheme,
    cardTheme: CardThemeData(
      color: AppColors.stone,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.canopy,
        foregroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.canopy,
        side: const BorderSide(color: AppColors.canopy),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.canopy),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      elevation: 0,
    ),
  );
}
