/// Garden inventory list screen (KAN-22).
///
/// Fetches all gardens for a user via GET /gardens/?user_id= and shows
/// them as cards. Tapping a garden is meant to navigate to the garden
/// detail screen (KAN-24) — not built yet, so that navigation is left as
/// a clearly marked TODO rather than referencing a class that doesn't
/// exist. The "add garden" button has the same situation with the
/// create/edit screen (KAN-23).
library;

import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import 'garden_detail_screen.dart';
import 'garden_form_screen.dart';
import 'garden_model.dart';

class GardenListScreen extends StatefulWidget {
  final String userId;

  const GardenListScreen({super.key, required this.userId});

  @override
  State<GardenListScreen> createState() => _GardenListScreenState();
}

class _GardenListScreenState extends State<GardenListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Garden> _gardens = [];

  @override
  void initState() {
    super.initState();
    _fetchGardens();
  }

  Future<void> _fetchGardens() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.instance.get(
        '/gardens/',
        queryParams: {'user_id': widget.userId},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map((item) => Garden.fromJson(item as Map<String, dynamic>))
            .toList();
        setState(() {
          _gardens = list;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Something went wrong loading your gardens. Please try again.';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not reach the server. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onGardenTapped(Garden garden) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GardenDetailScreen(garden: garden)),
    );
    // The detail screen may have edited this garden — simplest reliable
    // refresh is just re-fetching the whole list rather than tracking
    // which single item changed.
    _fetchGardens();
  }

  Future<void> _onAddGardenPressed() async {
    final result = await Navigator.of(context).push<Garden>(
      MaterialPageRoute(
          builder: (_) => GardenFormScreen(userId: widget.userId)),
    );

    if (result != null) {
      _fetchGardens();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Gardens')),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddGardenPressed,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchGardens,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (_gardens.isEmpty) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Center(
              child: Text('No gardens yet. Tap + to add your first one.'),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _gardens.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final garden = _gardens[index];
        return _GardenCard(
            garden: garden, onTap: () => _onGardenTapped(garden));
      },
    );
  }
}

class _GardenCard extends StatelessWidget {
  final Garden garden;
  final VoidCallback onTap;

  const _GardenCard({required this.garden, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      garden.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatGardenType(garden.gardenType),
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.soil),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.soil),
            ],
          ),
        ),
      ),
    );
  }
}
