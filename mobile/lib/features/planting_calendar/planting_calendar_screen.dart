/// Planting calendar screen (KAN-21).
///
/// Fetches recommendations for a garden from GET /recommendations/ and
/// displays each as a card: species identity, status chip (color + icon
/// + label per the design system — never color alone), confidence
/// treatment, planting window, harvest window, and the reasoning notes
/// that make "why was this recommended?" visible rather than hidden.
///
/// Filterable by category and sunlight requirement, matching the
/// backend's query parameters.
library;

import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/status_style.dart';
import 'date_format.dart';
import 'planting_recommendation.dart';

class PlantingCalendarScreen extends StatefulWidget {
  final String gardenId;

  const PlantingCalendarScreen({super.key, required this.gardenId});

  @override
  State<PlantingCalendarScreen> createState() => _PlantingCalendarScreenState();
}

class _PlantingCalendarScreenState extends State<PlantingCalendarScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<PlantingRecommendation> _recommendations = [];

  String? _selectedCategory;
  String? _selectedSunlight;

  static const List<String> _categoryOptions = [
    'vegetable',
    'herb',
    'fruit',
    'flower'
  ];
  static const List<String> _sunlightOptions = [
    'full_sun',
    'partial_sun',
    'partial_shade',
    'full_shade',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final queryParams = <String, dynamic>{'garden_id': widget.gardenId};
      if (_selectedCategory != null) {
        queryParams['category'] = _selectedCategory;
      }
      if (_selectedSunlight != null) {
        queryParams['sunlight'] = _selectedSunlight;
      }

      final response = await ApiClient.instance
          .get('/recommendations/', queryParams: queryParams);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map((item) =>
                PlantingRecommendation.fromJson(item as Map<String, dynamic>))
            .toList();
        setState(() {
          _recommendations = list;
          _isLoading = false;
        });
      } else if (response.statusCode == 400) {
        final detail =
            (response.data is Map) ? response.data['detail'] as String? : null;
        setState(() {
          _errorMessage = detail ??
              'This garden needs a location set before recommendations are available.';
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Garden not found.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Something went wrong loading recommendations. Please try again.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planting Calendar')),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration:
                  const InputDecoration(labelText: 'Category', isDense: true),
              items: _categoryOptions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
                _fetchRecommendations();
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedSunlight,
              decoration:
                  const InputDecoration(labelText: 'Sunlight', isDense: true),
              items: _sunlightOptions
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(s.replaceAll('_', ' '))))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedSunlight = value);
                _fetchRecommendations();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return const Center(
          child: Text('No matching plants found for these filters.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _recommendations.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) =>
          _RecommendationCard(recommendation: _recommendations[index]),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final PlantingRecommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final status = parsePlantingWindowStatus(recommendation.mainWindowStatus);
    final statusStyle = plantingWindowStyles[status]!;
    final confidence = parseConfidence(recommendation.confidence);
    final confidenceStyle = confidenceStyles[confidence]!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.commonName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        recommendation.scientificName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.soil,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(style: statusStyle),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _ConfidenceBadge(confidence: confidence, style: confidenceStyle),
            if (recommendation.mainWindow != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${_methodLabel(recommendation.mainMethod)}: '
                '${formatDateRange(recommendation.mainWindow!.start, recommendation.mainWindow!.end)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (recommendation.harvestWindow != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Expected harvest: '
                '${formatDateRange(recommendation.harvestWindow!.start, recommendation.harvestWindow!.end)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (recommendation.notes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              ...recommendation.notes.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    '• $note',
                    style: const TextStyle(fontSize: 13, color: AppColors.soil),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _methodLabel(String? method) {
    switch (method) {
      case 'transplant':
        return 'Transplant';
      case 'direct_sow':
        return 'Direct sow';
      default:
        return 'Plant';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final StatusStyle style;

  const _StatusChip({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.color),
          const SizedBox(width: 4),
          Text(style.label,
              style: TextStyle(
                  fontSize: 12,
                  color: style.color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final RecommendationConfidence confidence;
  final ConfidenceStyle style;

  const _ConfidenceBadge({required this.confidence, required this.style});

  String get _label {
    switch (confidence) {
      case RecommendationConfidence.high:
        return 'High confidence';
      case RecommendationConfidence.low:
        return 'Low confidence';
      case RecommendationConfidence.none:
        return 'Not enough data';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: style.filled ? AppColors.canopy : Colors.transparent,
        border: Border.all(color: AppColors.canopy),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          color: style.filled ? AppColors.paper : AppColors.canopy,
        ),
      ),
    );
  }
}
