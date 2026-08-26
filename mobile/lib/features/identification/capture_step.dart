/// Defines the guided photo-capture sequence for plant identification.
///
/// Scoped to what Pl@ntNet's organ parameter actually uses meaningfully
/// (leaf, flower, fruit, bark, or auto) rather than the full 8-angle
/// list in docs/01-product-requirements.md — a whole-plant shot (organ:
/// auto) plus a leaf close-up covers the common case well; flower is
/// offered but optional since not every plant is flowering when
/// photographed.
library;

class CaptureStep {
  final String label;
  final String instructions;
  final String
      organ; // matches backend's organ values: leaf/flower/fruit/bark/auto
  final bool isOptional;

  const CaptureStep({
    required this.label,
    required this.instructions,
    required this.organ,
    this.isOptional = false,
  });
}

const List<CaptureStep> captureSteps = [
  CaptureStep(
    label: 'Whole Plant',
    instructions: 'Fit the entire plant in frame, including its surroundings.',
    organ: 'auto',
  ),
  CaptureStep(
    label: 'Leaf Close-Up',
    instructions: 'Get close enough to show the leaf shape and edges clearly.',
    organ: 'leaf',
  ),
  CaptureStep(
    label: 'Flower (if present)',
    instructions: "Skip this if the plant isn't currently flowering.",
    organ: 'flower',
    isOptional: true,
  ),
];
