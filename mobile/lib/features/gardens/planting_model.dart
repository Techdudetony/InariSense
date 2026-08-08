/// Data model for a Planting, matching app/schemas/planting.py's
/// PlantingRead. Date fields stay as raw ISO strings (nullable) —
/// display formatting happens in the widgets that show them.
library;

class Planting {
  final String id;
  final String gardenBedId;
  final String userPlantId;
  final String plantingMethod;
  final String? indoorStartDate;
  final String? transplantDate;
  final String? directSowDate;
  final String? actualHarvestDate;

  Planting({
    required this.id,
    required this.gardenBedId,
    required this.userPlantId,
    required this.plantingMethod,
    this.indoorStartDate,
    this.transplantDate,
    this.directSowDate,
    this.actualHarvestDate,
  });

  factory Planting.fromJson(Map<String, dynamic> json) {
    return Planting(
      id: json['id'] as String,
      gardenBedId: json['garden_bed_id'] as String,
      userPlantId: json['user_plant_id'] as String,
      plantingMethod: json['planting_method'] as String,
      indoorStartDate: json['indoor_start_date'] as String?,
      transplantDate: json['transplant_date'] as String?,
      directSowDate: json['direct_sow_date'] as String?,
      actualHarvestDate: json['actual_harvest_date'] as String?,
    );
  }
}
