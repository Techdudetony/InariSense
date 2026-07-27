/// Status and confidence visual treatment, per docs/07-design-system.md.
///
/// Centralized here because the "color + icon + label, never color alone"
/// pattern applies to planting window status, identification confidence,
/// and (later) task priority — building this once now means every future
/// screen consumes it instead of re-deriving the same color/icon mapping.
library;

import 'package:flutter/material.dart';

import 'colors.dart';

/// Matches the main_window_status values returned by the backend's
/// recommendation engine (app/modules/gardens/recommendation/engine.py).
enum PlantingWindowStatus { early, ideal, late, unsuitable, insufficientData }

class StatusStyle {
  final Color color;
  final IconData icon;
  final String label;

  const StatusStyle(
      {required this.color, required this.icon, required this.label});
}

const Map<PlantingWindowStatus, StatusStyle> plantingWindowStyles = {
  PlantingWindowStatus.ideal: StatusStyle(
    color: AppColors.sprout,
    icon: Icons.check_circle_outline,
    label: 'Ideal',
  ),
  PlantingWindowStatus.early: StatusStyle(
    color: AppColors.bloom,
    icon: Icons.schedule,
    label: 'Early',
  ),
  PlantingWindowStatus.late: StatusStyle(
    color: AppColors.harvest,
    icon: Icons.hourglass_bottom,
    label: 'Late',
  ),
  PlantingWindowStatus.unsuitable: StatusStyle(
    color: AppColors.frost,
    icon: Icons.warning_amber_outlined,
    label: 'Unsuitable',
  ),
  PlantingWindowStatus.insufficientData: StatusStyle(
    color: AppColors.stone,
    icon: Icons.help_outline,
    label: 'Not enough data',
  ),
};

/// Parses the backend's snake_case status string into the enum. Falls
/// back to insufficientData for anything unrecognized, rather than
/// throwing — a status the UI doesn't understand should degrade to
/// "we don't know," never crash the screen.
PlantingWindowStatus parsePlantingWindowStatus(String raw) {
  switch (raw) {
    case 'ideal':
      return PlantingWindowStatus.ideal;
    case 'early':
      return PlantingWindowStatus.early;
    case 'late':
      return PlantingWindowStatus.late;
    case 'unsuitable':
      return PlantingWindowStatus.unsuitable;
    default:
      return PlantingWindowStatus.insufficientData;
  }
}

enum RecommendationConfidence { high, low, none }

RecommendationConfidence parseConfidence(String raw) {
  switch (raw) {
    case 'high':
      return RecommendationConfidence.high;
    case 'low':
      return RecommendationConfidence.low;
    default:
      return RecommendationConfidence.none;
  }
}

/// Confidence is styled as fill treatment (solid / outline / dashed
/// outline) rather than distinct hues, per the design system — it's a
/// different visual dimension than window status, and reusing the same
/// color language for both would blur the distinction between "when to
/// plant" and "how sure are we."
class ConfidenceStyle {
  final bool filled;
  final bool dashed;

  const ConfidenceStyle({required this.filled, required this.dashed});
}

const Map<RecommendationConfidence, ConfidenceStyle> confidenceStyle = {
  RecommendationConfidence.high: ConfidenceStyle(filled: true, dashed: false),
  RecommendationConfidence.low: ConfidenceStyle(filled: false, dashed: false),
  RecommendationConfidence.none: ConfidenceStyle(filled: false, dashed: true),
};
