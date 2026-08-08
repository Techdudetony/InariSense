/// Bottom-nav home shell — the app's real entry point once user session
/// bootstrap completes.
///
/// Tabs without a built screen yet show a clearly labeled "not built
/// yet" placeholder (with a Jira reference where one exists) instead of
/// being hidden — the nav structure reflects the app's intended shape
/// from docs/01-product-requirements.md even before every tab has real
/// content, same TODO-placeholder pattern used throughout the rest of
/// the app.
library;

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../gardens/garden_list_screen.dart';

class HomeShell extends StatefulWidget {
  final String userId;

  const HomeShell({super.key, required this.userId});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _HomeTabPlaceholder(),
      GardenListScreen(userId: widget.userId),
      const _NotBuiltYetTab(label: 'Identify', jiraKey: 'KAN-6'),
      const _NotBuiltYetTab(label: 'Tasks', jiraKey: 'KAN-8'),
      const _NotBuiltYetTab(label: 'Journal', jiraKey: 'KAN-10'),
      const _NotBuiltYetTab(label: 'Learn', jiraKey: null),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grass_outlined),
            selectedIcon: Icon(Icons.grass),
            label: 'My Garden',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Identify',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}

class _HomeTabPlaceholder extends StatelessWidget {
  const _HomeTabPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InariSense')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Home dashboard not yet built. Use the My Garden tab to manage your gardens.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _NotBuiltYetTab extends StatelessWidget {
  final String label;
  final String? jiraKey;

  const _NotBuiltYetTab({required this.label, required this.jiraKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text(
          jiraKey != null
              ? '$label screen not built yet ($jiraKey)'
              : '$label screen not built yet',
          style: const TextStyle(color: AppColors.soil),
        ),
      ),
    );
  }
}
