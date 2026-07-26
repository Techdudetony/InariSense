/// Location setup screen (KAN-13).
///
/// Offers two paths to set a garden's location:
/// 1. "Use My Current Location" — requests foreground-only location
///    permission, reverse-geocodes the device coordinates to a readable
///    address locally, then sends that address to the backend.
/// 2. Manual entry — a free-text address/city/ZIP field, for when the
///    user declines permission or prefers not to share GPS location at
///    all.
///
/// Both paths converge on the same backend call
/// (POST /garden-locations/from-address) so there's only one code path
/// to trust for the actual geocode+zone/frost+save logic — this screen's
/// job is just getting a usable address string by one method or another.
///
/// Never requests background location — only ever asks for
/// "while in use" permission, per the privacy principles in
/// docs/01-product-requirements.md.
library;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/api_client.dart';

class LocationSetupScreen extends StatefulWidget {
  final String gardenId;

  const LocationSetupScreen({super.key, required this.gardenId});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  final _addressController = TextEditingController();
  // geocoding v5+ wraps everything in a Geocoding instance rather than
  // exposing top-level functions — see the package's migration guide for
  // 5.0.0. One instance is enough; it holds no per-call state.
  final _geocoding = Geocoding();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<bool> _ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // whileInUse is the target state — we deliberately never request
    // "always" (background) permission from the OS in the first place,
    // so `always` only shows up here if the user granted more than we
    // asked for; either is fine to proceed with.
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  String _formatPlacemark(Placemark placemark) {
    final parts = [
      placemark.locality,
      placemark.administrativeArea,
      placemark.postalCode,
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

    if (parts.isNotEmpty) return parts;
    return placemark.name?.trim().isNotEmpty == true
        ? placemark.name!
        : 'Unknown location';
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage =
              'Location services are turned off on this device. Enable them, or enter your address below instead.';
        });
        return;
      }

      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage =
              "Location permission denied. That's okay — enter your address, city, or ZIP below instead.";
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final address = placemarks.isNotEmpty
          ? _formatPlacemark(placemarks.first)
          : '${position.latitude}, ${position.longitude}';

      await _submitAddress(address);
    } catch (_) {
      setState(() {
        _errorMessage =
            'Could not determine your current location. Enter your address, city, or ZIP below instead.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitManualAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() {
        _errorMessage = 'Enter an address, city, or ZIP code first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _submitAddress(address);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAddress(String address) async {
    try {
      final response = await ApiClient.instance.post(
        '/garden-locations/from-address',
        body: {'garden_id': widget.gardenId, 'address': address},
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.of(context).pop(response.data);
        return;
      }

      if (response.statusCode == 404) {
        setState(() {
          _errorMessage =
              "Couldn't find that location. Try a more specific address, city, or ZIP.";
        });
      } else if (response.statusCode == 409) {
        setState(() {
          _errorMessage = 'This garden already has a saved location.';
        });
      } else {
        setState(() {
          _errorMessage =
              'Something went wrong saving your location. Please try again.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Could not reach the server. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Garden Location')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "InariSense uses your location to recommend planting times suited "
              "to your climate. We only use it while you're using the app — "
              "never in the background.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('Use My Current Location'),
              onPressed: _isLoading ? null : _useCurrentLocation,
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _addressController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Address, city, or ZIP code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitManualAddress,
              child: const Text('Save Location'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
