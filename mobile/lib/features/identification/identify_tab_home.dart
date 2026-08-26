/// Identify tab entry point.
///
/// Deliberately NOT the camera screen itself — HomeShell's IndexedStack
/// builds every tab eagerly at launch, so putting GuidedCaptureScreen
/// directly here would initialize the camera (and prompt for
/// permission) the moment the app opens, before the user has asked to
/// identify anything. This lightweight screen defers that until the
/// user actually taps the button.
library;

import 'package:flutter/material.dart';

import '../../core/theme/spacing.dart';
import 'guided_capture_screen.dart';

class IdentifyTabHome extends StatelessWidget {
  final String userId;

  const IdentifyTabHome({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identify')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined, size: 64),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Take a few photos of a plant to identify it.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GuidedCaptureScreen(userId: userId),
                    ),
                  );
                },
                child: const Text('Start Identification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
