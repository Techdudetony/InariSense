/// Add planting form (KAN-25, part 2).
///
/// Creating a Planting requires a user_plant_id, which itself requires a
/// species_id — but there's no dedicated species browser screen anywhere
/// in the app yet. Rather than block this form on that missing piece,
/// it fetches the full species list for a simple dropdown and creates
/// the UserPlant inline as part of submission. If a real species
/// browser/search screen gets built later, this dropdown can be
/// replaced with a "pick from browser" flow without changing anything
/// else about how planting creation works.
library;

import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/theme/spacing.dart';
import 'plant_species_option.dart';
import 'planting_model.dart';

const List<String> plantingMethodOptions = [
  'indoor_seed_start',
  'direct_sow',
  'transplant'
];

String _formatPlantingMethod(String raw) => raw.replaceAll('_', ' ');

String _formatDateForApi(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class AddPlantingScreen extends StatefulWidget {
  final String gardenBedId;
  final String userId;

  const AddPlantingScreen(
      {super.key, required this.gardenBedId, required this.userId});

  @override
  State<AddPlantingScreen> createState() => _AddPlantingScreenState();
}

class _AddPlantingScreenState extends State<AddPlantingScreen> {
  final _nicknameController = TextEditingController();

  bool _isLoadingSpecies = true;
  String? _loadErrorMessage;
  List<PlantSpeciesOption> _speciesOptions = [];
  String? _selectedSpeciesId;

  String _plantingMethod = plantingMethodOptions.first;
  DateTime? _indoorStartDate;
  DateTime? _transplantDate;
  DateTime? _directSowDate;

  bool _isSubmitting = false;
  String? _submitErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSpecies();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _fetchSpecies() async {
    setState(() {
      _isLoadingSpecies = true;
      _loadErrorMessage = null;
    });

    try {
      final response = await ApiClient.instance.get('/plant-species/');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map((item) =>
                PlantSpeciesOption.fromJson(item as Map<String, dynamic>))
            .toList();
        setState(() {
          _speciesOptions = list;
          _isLoadingSpecies = false;
        });
      } else {
        setState(() {
          _loadErrorMessage = 'Could not load plant species. Please try again.';
          _isLoadingSpecies = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadErrorMessage =
            'Could not reach the server. Check your connection and try again.';
        _isLoadingSpecies = false;
      });
    }
  }

  Future<void> _pickDate(
      void Function(DateTime?) onPicked, DateTime? currentValue) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  Future<void> _submit() async {
    if (_selectedSpeciesId == null) {
      setState(() => _submitErrorMessage = 'Select a plant species first.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitErrorMessage = null;
    });

    try {
      final userPlantResponse = await ApiClient.instance.post(
        '/user-plants/',
        body: {
          'user_id': widget.userId,
          'species_id': _selectedSpeciesId,
          if (_nicknameController.text.trim().isNotEmpty)
            'nickname': _nicknameController.text.trim(),
        },
      );

      if (!mounted) return;

      if (userPlantResponse.statusCode != 201) {
        setState(() {
          _submitErrorMessage =
              'Something went wrong saving this plant. Please try again.';
          _isSubmitting = false;
        });
        return;
      }

      final userPlantId =
          (userPlantResponse.data as Map<String, dynamic>)['id'] as String;

      final plantingResponse = await ApiClient.instance.post(
        '/plantings/',
        body: {
          'garden_bed_id': widget.gardenBedId,
          'user_plant_id': userPlantId,
          'planting_method': _plantingMethod,
          if (_indoorStartDate != null)
            'indoor_start_date': _formatDateForApi(_indoorStartDate!),
          if (_transplantDate != null)
            'transplant_date': _formatDateForApi(_transplantDate!),
          if (_directSowDate != null)
            'direct_sow_date': _formatDateForApi(_directSowDate!),
        },
      );

      if (!mounted) return;

      if (plantingResponse.statusCode == 201) {
        final planting =
            Planting.fromJson(plantingResponse.data as Map<String, dynamic>);
        Navigator.of(context).pop(planting);
      } else {
        setState(() {
          _submitErrorMessage =
              'Plant saved, but something went wrong recording the planting. Please try again.';
          _isSubmitting = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitErrorMessage =
            'Could not reach the server. Check your connection and try again.';
        _isSubmitting = false;
      });
    }
  }

  Widget _buildDateRow(
      String label, DateTime? value, void Function(DateTime?) onPicked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(value == null
                ? '$label: not set'
                : '$label: ${_formatDateForApi(value)}'),
          ),
          TextButton(
            onPressed: () => _pickDate(onPicked, value),
            child: const Text('Pick date'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Planting')),
      body: _isLoadingSpecies
          ? const Center(child: CircularProgressIndicator())
          : _loadErrorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child:
                        Text(_loadErrorMessage!, textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSpeciesId,
                      decoration:
                          const InputDecoration(labelText: 'Plant species'),
                      items: _speciesOptions
                          .map(
                            (species) => DropdownMenuItem(
                              value: species.id,
                              child: Text(
                                  '${species.commonName} (${species.scientificName})'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSpeciesId = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                          labelText: 'Nickname (optional)'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _plantingMethod,
                      decoration:
                          const InputDecoration(labelText: 'Planting method'),
                      items: plantingMethodOptions
                          .map(
                            (method) => DropdownMenuItem(
                              value: method,
                              child: Text(_formatPlantingMethod(method)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _plantingMethod = value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildDateRow(
                      'Indoor start date',
                      _indoorStartDate,
                      (date) => _indoorStartDate = date,
                    ),
                    _buildDateRow(
                      'Transplant date',
                      _transplantDate,
                      (date) => _transplantDate = date,
                    ),
                    _buildDateRow(
                      'Direct sow date',
                      _directSowDate,
                      (date) => _directSowDate = date,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (_submitErrorMessage != null) ...[
                      Text(_submitErrorMessage!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add Planting'),
                    ),
                  ],
                ),
    );
  }
}
