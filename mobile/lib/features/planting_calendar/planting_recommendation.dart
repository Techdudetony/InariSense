/// Data model for a single planting recommendation, matching the shape
/// returned by GET /recommendations/ (app/schemas/recommendation.py).
library;

class DateWindow {
  final String start; // ISO date string, e.g. "2026-04-12"
  final String end;

  DateWindow({required this.start, required this.end});

  factory DateWindow.fromJson(Map<String, dynamic> json) {
    return DateWindow(
        start: json['start'] as String, end: json['end'] as String);
  }
}

class PlantingRecommendation {
  final String speciesId;
  final String commonName;
  final String scientificName;
  final String confidence; // "high" | "low" | "none"
  final String
      frostDataSource; // "garden_location" | "zone_average" | "unavailable"
  final String? mainMethod; // "direct_sow" | "transplant" | null
  final DateWindow? mainWindow;
  final String mainWindowStatus;
  final DateWindow? indoorStartWindow;
  final DateWindow? harvestWindow;
  final List<String> notes;

  PlantingRecommendation({
    required this.speciesId,
    required this.commonName,
    required this.scientificName,
    required this.confidence,
    required this.frostDataSource,
    required this.mainMethod,
    required this.mainWindow,
    required this.mainWindowStatus,
    required this.indoorStartWindow,
    required this.harvestWindow,
    required this.notes,
  });

  factory PlantingRecommendation.fromJson(Map<String, dynamic> json) {
    return PlantingRecommendation(
      speciesId: json['species_id'] as String,
      commonName: json['common_name'] as String,
      scientificName: json['scientific_name'] as String,
      confidence: json['confidence'] as String,
      frostDataSource: json['frost_data_source'] as String,
      mainMethod: json['main_method'] as String?,
      mainWindow: json['main_window'] != null
          ? DateWindow.fromJson(json['main_window'] as Map<String, dynamic>)
          : null,
      mainWindowStatus: json['main_window_status'] as String,
      indoorStartWindow: json['indoor_start_window'] != null
          ? DateWindow.fromJson(
              json['indoor_start_window'] as Map<String, dynamic>)
          : null,
      harvestWindow: json['harvest_window'] != null
          ? DateWindow.fromJson(json['harvest_window'] as Map<String, dynamic>)
          : null,
      notes: (json['notes'] as List<dynamic>).map((n) => n as String).toList(),
    );
  }
}
