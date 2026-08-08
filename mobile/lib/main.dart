// InariSense mobile entry point.
//
// This is a minimal scaffold: a Riverpod-wrapped MaterialApp with a single
// placeholder home screen. Feature screens (Identify, My Garden, Tasks,
// Journal, Learn) get built out under lib/features/ as their own branches,
// per docs/03-architecture.md.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inarisense/core/session_bootstrap.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: InariSenseApp()));
}

class InariSenseApp extends StatelessWidget {
  const InariSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InariSense',
      theme: buildAppTheme(),
      home: const SessionBootstrap(),
    );
  }
}
