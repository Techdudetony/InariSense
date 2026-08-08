/// Garden detail screen (KAN-24, updated for KAN-25).
///
/// Shows garden info, its location (or a prompt to set one, reusing
/// LocationSetupScreen from KAN-13), and its beds with plantings inside
/// each. Edit navigates to GardenFormScreen (KAN-23). "Add Bed" and
/// per-bed "Add Planting" now navigate to real forms (KAN-25).
library;

import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../location_setup/location_setup_screen.dart';
import 'add_bed_screen.dart';
import 'add_planting_screen.dart';
import 'garden_bed_model.dart';
import 'garden_form_screen.dart';
import 'garden_location_model.dart';
import 'garden_model.dart';
import 'planting_model.dart';

class GardenDetailScreen extends StatefulWidget {
  final Garden garden;

  const GardenDetailScreen({super.key, required this.garden});

  @override
  State<GardenDetailScreen> createState() => _GardenDetailScreenState();
}

class _GardenDetailScreenState extends State<GardenDetailScreen> {
  late Garden _garden;
  GardenLocationInfo? _location;
  List<GardenBed> _beds = [];
  Map<String, List<Planting>> _plantingsByBedId = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _garden = widget.garden;
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locationResponse = await ApiClient.instance.get(
        '/garden-locations/',
        queryParams: {'garden_id': _garden.id},
      );

      GardenLocationInfo? location;
      if (locationResponse.statusCode == 200) {
        final list = locationResponse.data as List<dynamic>;
        if (list.isNotEmpty) {
          location =
              GardenLocationInfo.fromJson(list.first as Map<String, dynamic>);
        }
      }

      final bedsResponse = await ApiClient.instance.get(
        '/garden-beds/',
        queryParams: {'garden_id': _garden.id},
      );

      List<GardenBed> beds = [];
      if (bedsResponse.statusCode == 200) {
        beds = (bedsResponse.data as List<dynamic>)
            .map((item) => GardenBed.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      final plantingsByBed = <String, List<Planting>>{};
      final plantingResponses = await Future.wait(
        beds.map(
          (bed) => ApiClient.instance
              .get('/plantings/', queryParams: {'garden_bed_id': bed.id}),
        ),
      );
      for (var i = 0; i < beds.length; i++) {
        final response = plantingResponses[i];
        if (response.statusCode == 200) {
          plantingsByBed[beds[i].id] = (response.data as List<dynamic>)
              .map((item) => Planting.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          plantingsByBed[beds[i].id] = [];
        }
      }

      if (!mounted) return;
      setState(() {
        _location = location;
        _beds = beds;
        _plantingsByBedId = plantingsByBed;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not reach the server. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onEditPressed() async {
    final result = await Navigator.of(context).push<Garden>(
      MaterialPageRoute(
        builder: (_) =>
            GardenFormScreen(userId: _garden.userId, existingGarden: _garden),
      ),
    );

    if (result != null) {
      setState(() => _garden = result);
    }
  }

  Future<void> _onSetLocationPressed() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => LocationSetupScreen(gardenId: _garden.id)),
    );
    // LocationSetupScreen pops with the created location's raw response
    // data rather than a typed model, so simplest reliable path is just
    // re-fetching everything on return instead of trying to parse its
    // pop result here.
    _fetchAll();
  }

  Future<void> _onAddBedPressed() async {
    final result = await Navigator.of(context).push<GardenBed>(
      MaterialPageRoute(builder: (_) => AddBedScreen(gardenId: _garden.id)),
    );

    if (result != null) {
      _fetchAll();
    }
  }

  Future<void> _onAddPlantingPressed(GardenBed bed) async {
    final result = await Navigator.of(context).push<Planting>(
      MaterialPageRoute(
        builder: (_) =>
            AddPlantingScreen(gardenBedId: bed.id, userId: _garden.userId),
      ),
    );

    if (result != null) {
      _fetchAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_garden.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _onEditPressed),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddBedPressed,
        tooltip: 'Add bed',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(onRefresh: _fetchAll, child: _buildBody()),
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

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildGardenInfoCard(),
        const SizedBox(height: AppSpacing.lg),
        _buildLocationSection(),
        const SizedBox(height: AppSpacing.lg),
        Text('Beds', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        if (_beds.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text('No beds yet. Tap + to add one.'),
          )
        else
          ..._beds.map(_buildBedCard),
      ],
    );
  }

  Widget _buildGardenInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatGardenType(_garden.gardenType)),
            if (_garden.sunlightExposure != null)
              Text('Sunlight: ${_garden.sunlightExposure}'),
            if (_garden.soilType != null) Text('Soil: ${_garden.soilType}'),
            if (_garden.soilPh != null) Text('Soil pH: ${_garden.soilPh}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    if (_location == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('No location set for this garden yet.'),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                  onPressed: _onSetLocationPressed,
                  child: const Text('Set Location')),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_location!.resolvedAddress ?? 'Location set'),
            if (_location!.usdaZone != null)
              Text('USDA Zone: ${_location!.usdaZone}'),
          ],
        ),
      ),
    );
  }

  Widget _buildBedCard(GardenBed bed) {
    final plantings = _plantingsByBedId[bed.id] ?? [];
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bed.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _onAddPlantingPressed(bed),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Planting'),
                ),
              ],
            ),
            if (bed.dimensions != null)
              Text(bed.dimensions!,
                  style: const TextStyle(fontSize: 13, color: AppColors.soil)),
            const SizedBox(height: AppSpacing.sm),
            if (plantings.isEmpty)
              const Text('Nothing planted here yet.',
                  style: TextStyle(fontSize: 13))
            else
              Text('${plantings.length} planting(s)',
                  style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
