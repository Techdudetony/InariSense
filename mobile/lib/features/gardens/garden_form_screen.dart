/// Create/edit garden screen (KAN-23).
///
/// One screen handles both modes: pass an existing Garden to edit it,
/// or omit it to create a new one. POSTs to /gardens/ for create, PATCHes
/// /gardens/{id} for edit. On success, pops back with the resulting
/// Garden so the caller (garden list screen) can refresh without a full
/// re-fetch.
library;

import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/theme/spacing.dart';
import 'garden_model.dart';

class GardenFormScreen extends StatefulWidget {
  final String userId;
  final Garden? existingGarden;

  const GardenFormScreen(
      {super.key, required this.userId, this.existingGarden});

  bool get isEditing => existingGarden != null;

  @override
  State<GardenFormScreen> createState() => _GardenFormScreenState();
}

class _GardenFormScreenState extends State<GardenFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _sunlightController;
  late final TextEditingController _soilTypeController;
  late final TextEditingController _soilPhController;
  late final TextEditingController _drainageController;
  late final TextEditingController _irrigationController;
  late final TextEditingController _notesController;

  late String _gardenType;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingGarden;

    _nameController = TextEditingController(text: existing?.name ?? '');
    _sunlightController =
        TextEditingController(text: existing?.sunlightExposure ?? '');
    _soilTypeController = TextEditingController(text: existing?.soilType ?? '');
    _soilPhController =
        TextEditingController(text: existing?.soilPh?.toString() ?? '');
    _drainageController = TextEditingController(text: existing?.drainage ?? '');
    _irrigationController =
        TextEditingController(text: existing?.irrigationMethod ?? '');
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _gardenType = existing?.gardenType ?? gardenTypeOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sunlightController.dispose();
    _soilTypeController.dispose();
    _soilPhController.dispose();
    _drainageController.dispose();
    _irrigationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final soilPhText = _soilPhController.text.trim();
    final body = <String, dynamic>{
      'name': _nameController.text.trim(),
      'garden_type': _gardenType,
      'sunlight_exposure': _emptyToNull(_sunlightController.text),
      'soil_type': _emptyToNull(_soilTypeController.text),
      'soil_ph': soilPhText.isEmpty ? null : double.tryParse(soilPhText),
      'drainage': _emptyToNull(_drainageController.text),
      'irrigation_method': _emptyToNull(_irrigationController.text),
      'notes': _emptyToNull(_notesController.text),
    };

    try {
      final response = widget.isEditing
          ? await ApiClient.instance
              .patch('/gardens/${widget.existingGarden!.id}', body: body)
          : await ApiClient.instance
              .post('/gardens/', body: {...body, 'user_id': widget.userId});

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final garden = Garden.fromJson(response.data as Map<String, dynamic>);
        Navigator.of(context).pop(garden);
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'This garden no longer exists.';
          _isSubmitting = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Something went wrong saving this garden. Please try again.';
          _isSubmitting = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not reach server. Check your connection and try again.';
        _isSubmitting = false;
      });
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.isEditing ? 'Edit Garden' : 'New Garden')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Name is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _gardenType,
              decoration: const InputDecoration(labelText: 'Garden type'),
              items: gardenTypeOptions
                  .map((type) => DropdownMenuItem(
                      value: type, child: Text(formatGardenType(type))))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _gardenType = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _sunlightController,
              decoration: const InputDecoration(
                  labelText: 'Sunlight exposure (optional)'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _soilTypeController,
              decoration:
                  const InputDecoration(labelText: 'Soil type (optional)'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _soilPhController,
              decoration:
                  const InputDecoration(labelText: 'Soil pH (optional)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                return double.tryParse(value.trim()) == null
                    ? 'Enter a valid number'
                    : null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _drainageController,
              decoration:
                  const InputDecoration(labelText: 'Drainage (optional)'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _irrigationController,
              decoration: const InputDecoration(
                  labelText: 'Irrigation method (optional)'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_errorMessage != null) ...[
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
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
                  : Text(widget.isEditing ? 'Save Changes' : 'Create Garden'),
            ),
          ],
        ),
      ),
    );
  }
}
