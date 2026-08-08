/// Data model for a GardenBed, matching app/schemas/garden_bed.py's
/// GardenBedRead.
library;

class GardenBed {
  final String id;
  final String gardenId;
  final String name;
  final bool isContainer;
  final String? dimensions;
  final String? containerSize;
  final String? bedDepth;
  final String? notes;

  GardenBed({
    required this.id,
    required this.gardenId,
    required this.name,
    required this.isContainer,
    this.dimensions,
    this.containerSize,
    this.bedDepth,
    this.notes,
  });

  factory GardenBed.fromJson(Map<String, dynamic> json) {
    return GardenBed(
      id: json['id'] as String,
      gardenId: json['garden_id'] as String,
      name: json['name'] as String,
      isContainer: json['is_container'] as bool,
      dimensions: json['dimensions'] as String?,
      containerSize: json['container_size'] as String?,
      bedDepth: json['bed_depth'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
