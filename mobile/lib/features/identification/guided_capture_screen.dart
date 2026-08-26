/// Guided photo capture screen for plant identification (KAN-29).
///
/// Walks the user through capture_step.dart's step sequence, then
/// uploads everything to POST /identifications/. A dedicated results
/// screen is KAN-30 (not built yet) — this shows a minimal inline
/// summary of what came back rather than blocking on that screen
/// existing first, same TODO-placeholder pattern used elsewhere in the
/// app.
library;

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import 'capture_step.dart';

class GuidedCaptureScreen extends StatefulWidget {
  final String userId;

  const GuidedCaptureScreen({super.key, required this.userId});

  @override
  State<GuidedCaptureScreen> createState() => _GuidedCaptureScreenState();
}

class _GuidedCaptureScreenState extends State<GuidedCaptureScreen> {
  CameraController? _controller;
  bool _isInitializingCamera = true;
  String? _cameraError;

  int _currentStepIndex = 0;
  final Map<int, XFile> _capturedPhotos = {};

  bool _isUploading = false;
  String? _uploadError;
  List<dynamic>? _resultCandidates; // raw decoded candidates, see class doc

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _cameraError = 'No camera found on this device.';
          _isInitializingCamera = false;
        });
        return;
      }

      final controller = CameraController(cameras.first, ResolutionPreset.high);
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitializingCamera = false;
      });
    } on CameraException catch (_) {
      if (!mounted) return;
      setState(() {
        _cameraError =
            'Could not access the camera. Check camera permissions and try again.';
        _isInitializingCamera = false;
      });
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;

    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedPhotos[_currentStepIndex] = file;
      });
    } on CameraException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(
          content: Text('Could not take the photo. Try again.')));
    }
  }

  void _retake() {
    setState(() {
      _capturedPhotos.remove(_currentStepIndex);
    });
  }

  void _goToStep(int index) {
    setState(() {
      _currentStepIndex = index;
    });
  }

  bool get _allRequiredStepsCaptured {
    for (var i = 0; i < captureSteps.length; i++) {
      if (!captureSteps[i].isOptional && !_capturedPhotos.containsKey(i)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_allRequiredStepsCaptured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Capture all required photos before submitting.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      final fields = <MapEntry<String, String>>[
        MapEntry('user_id', widget.userId)
      ];
      final imageParts = <MultipartImagePart>[];

      final sortedEntries = _capturedPhotos.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      for (final entry in sortedEntries) {
        final stepIndex = entry.key;
        final xfile = entry.value;
        final bytes = await xfile.readAsBytes();
        final organ = captureSteps[stepIndex].organ;

        fields.add(MapEntry('organs', organ));
        imageParts.add(
          MultipartImagePart(
              fieldName: 'images', bytes: bytes, filename: '$stepIndex.jpg'),
        );
      }

      final response = await ApiClient.instance.postMultipart(
        '/identifications/',
        fields: fields,
        imageParts: imageParts,
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _resultCandidates = data['candidates'] as List<dynamic>;
          _isUploading = false;
        });
      } else {
        setState(() {
          _uploadError =
              'Something went wrong identifying this plant. Please try again.';
          _isUploading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _uploadError =
            'Could not reach the server. Check your connection and try again.';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identify a Plant')),
      body: _resultCandidates != null
          ? _buildResultsPlaceholder()
          : _isUploading
              ? const Center(child: CircularProgressIndicator())
              : _buildCaptureFlow(),
    );
  }

  Widget _buildCaptureFlow() {
    if (_isInitializingCamera) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cameraError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            _cameraError!,
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final step = captureSteps[_currentStepIndex];
    final captured = _capturedPhotos[_currentStepIndex];

    return Column(
      children: [
        _buildStepTabs(),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              Text(step.instructions,
                  style: const TextStyle(fontSize: 14, color: AppColors.soil)),
            ],
          ),
        ),
        Expanded(
          child: captured != null
              ? _buildCapturedPreview(captured)
              : AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
        ),
        _buildStepControls(step, captured),
      ],
    );
  }

  Widget _buildStepTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(captureSteps.length, (index) {
          final isDone = _capturedPhotos.containsKey(index);
          final isCurrent = index == _currentStepIndex;
          return GestureDetector(
            onTap: () => _goToStep(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.sprout
                    : (isCurrent ? AppColors.canopy : AppColors.stone),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCapturedPreview(XFile file) {
    return Image.file(File(file.path), fit: BoxFit.contain);
  }

  Widget _buildStepControls(CaptureStep step, XFile? captured) {
    final isLastStep = _currentStepIndex == captureSteps.length - 1;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          if (_uploadError != null) ...[
            Text(_uploadError!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (captured == null)
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                      onPressed: _retake, child: const Text('Retake')),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLastStep
                        ? (_allRequiredStepsCaptured ? _submit : null)
                        : () => _goToStep(_currentStepIndex + 1),
                    child: Text(isLastStep ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
          if (step.isOptional && captured == null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed:
                  isLastStep ? _submit : () => _goToStep(_currentStepIndex + 1),
              child: const Text('Skip this step'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsPlaceholder() {
    final candidates = _resultCandidates!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const Text(
          'A dedicated results screen with confidence explanations is coming soon (KAN-30). '
          'Here\'s the raw match data for now:',
          style: TextStyle(color: AppColors.soil),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (candidates.isEmpty)
          const Text(
              'No plant could be identified from these photos. Try again with clearer, closer photos.')
        else
          ...candidates.map((c) {
            final map = c as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      map['common_name'] as String,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      map['scientific_name'] as String,
                      style: const TextStyle(
                          fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Confidence: ${map['confidence_label']}'),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
