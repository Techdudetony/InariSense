/// Data model for a GardenLocation, matching
/// app/schemas/garden_location.py's GardenLocationRead.
library;

class GardenLocationInfo {
  final String id;
  final String gardenId;
  final double? latitude;
  final double? longitude;
  final String? resolvedAddress;
  final String? usdaZone;
  final String? zoneSource;
  final String? frostSource;

  GardenLocationInfo({
    required this.id,
    required this.gardenId,
    this.latitude,
    this.longitude,
    this.resolvedAddress,
    this.usdaZone,
    this.zoneSource,
    this.frostSource,
  });

  factory GardenLocationInfo.fromJson(Map<String, dynamic> json) {
    return GardenLocationInfo(
      id: json['id'] as String,
      gardenId: json['garden_id'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      resolvedAddress: json['resolved_address'] as String?,
      usdaZone: json['usda_zone'] as String?,
      zoneSource: json['zone_source'] as String?,
      frostSource: json['frost_source'] as String?,
    );
  }
}
