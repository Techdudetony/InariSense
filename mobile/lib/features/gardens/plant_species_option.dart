/// Minimal PlantSpecies model — just enough for a selection dropdown.
/// Not the full growing-requirement fields from the backend schema,
/// since nothing in the mobile app needs those yet.
library;

class PlantSpeciesOption {
  final String id;
  final String commonName;
  final String scientificName;

  PlantSpeciesOption(
      {required this.id,
      required this.commonName,
      required this.scientificName});

  factory PlantSpeciesOption.fromJson(Map<String, dynamic> json) {
    return PlantSpeciesOption(
      id: json['id'] as String,
      commonName: json['common_name'] as String,
      scientificName: json['scientific_name'] as String,
    );
  }
}
