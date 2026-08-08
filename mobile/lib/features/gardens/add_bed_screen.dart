/// Add garden bed form (KAN-25, part 1).
library;

import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/theme/spacing.dart';
import 'garden_bed_model.dart';

class AddBedScreen extends StatefulWidget {
  final String gardenId;

  const AddBedScreen({super.key, required this.gardenId});

  @override
  State<AddBedScreen> createState() => _AddBedScreenState();
}

class _AddBedScreenState extends State<AddBedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _containerSizeController = TextEditingController();
  final _bedDepthController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isContainer = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _dimensionsController.dispose();
    _containerSizeController.dispose();
    _bedDepthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.instance.post(
        '/garden-beds/',
        body: {
          'garden_id': widget.gardenId,
          'name': _nameController.text.trim(),
          'is_container': _isContainer,
          'dimensions': _emptyToNull(_dimensionsController.text),
          'container_size': _emptyToNull(_containerSizeController.text),
          'bed_depth': _emptyToNull(_bedDepthController.text),
          'notes': _emptyToNull(_notesController.text),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final bed = GardenBed.fromJson(response.data as Map<String, dynamic>);
        Navigator.of(context).pop(bed);
      } else {
        setState(() {
          _errorMessage =
              'Something went wrong saving this bed. Please try again.';
          _isSubmitting = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not reach the server. Check your connection and try again.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bed')),
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('This is a container'),
              value: _isContainer,
              onChanged: (value) => setState(() => _isContainer = value),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _dimensionsController,
              decoration: const InputDecoration(
                  labelText: 'Dimensions (optional, e.g. "4x8 ft")'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _containerSizeController,
              decoration: const InputDecoration(
                  labelText: 'Container size (optional, e.g. "5 gallon")'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _bedDepthController,
              decoration:
                  const InputDecoration(labelText: 'Bed depth (optional)'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
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
                  : const Text('Add Bed'),
            ),
          ],
        ),
      ),
    );
  }
}
