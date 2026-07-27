/// Color tokens matching docs/07-design-system.md.
///
/// Keep this file as the single source of truth for these values —
/// widgets should reference AppColors.canopy etc., never hard-code a hex
/// value inline, so a future palette adjustment (like the `stone` fix)
/// only needs to happen in one place.
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color soil = Color(0xFF3D2B1F);
  static const Color canopy = Color(0xFF2F5233);
  static const Color sprout = Color(0xFF7FB069);
  static const Color bloom = Color(0xFFE08E45);
  static const Color frost = Color(0xFFA8C5D6);
  static const Color harvest = Color(0xFFC9A227);
  static const Color paper = Color(0xFFFAF7F2);
  static const Color stone = Color(0xFFD3C7B4);
  static const Color ink = Color(0xFF1A1A1A);
  static const Color error = Color(0xFFB3264E);
}
