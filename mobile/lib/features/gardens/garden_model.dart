/// Data model for a Garden, matching app/schemas/garden.py's FardenRead.
library;

class Garden {
  final String id;
  final String userId;
  final String name;
  final String gardenType;
  final String? sunlightExposure;
  final String? soilType;
  final double? soilPh;
  final String? drainage;
  final String? irrigationMethod;
  final String? notes;

  Garden({
    required this.id,
    required this.userId,
    required this.name,
    required this.gardenType,
    this.sunlightExposure,
    this.soilType,
    this.soilPh,
    this.drainage,
    this.irrigationMethod,
    this.notes,
  });

  factory Garden.fromJson(Map<String, dynamic> json) {
    return Garden(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      gardenType: json['garden_type'] as String,
      sunlightExposure: json['sunlight_exposure'] as String?,
      soilType: json['soil_type'] as String?,
      soilPh: (json['soil_ph'] as num?)?.toDouble(),
      drainage: json['drainage'] as String?,
      irrigationMethod: json['irrigation_method'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// Matches GardenType in app/models/garden.py — kept in sync manually
/// since Dart can't share an enum directly with the Python backend.+
const List<String> gardenTypeOptions = [
  'raised_bed',
  'in_ground',
  'container',
  'indoor',
  'greenhouse',
  'hydroponic',
  'community',
  'orchard',
  'lawn',
  'landscape_bed',
];

String formatGardenType(String raw) => raw.replaceAll('_', ' ');
