import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:forui/forui.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();

  late LatLng _selectedLocation;

  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();

    _selectedLocation = LatLng(
      widget.initialLat ?? 24.8607,
      widget.initialLng ?? 67.0011,
    );
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    final latLng = LatLng(position.latitude, position.longitude);

    _mapController.move(latLng, 16);

    setState(() {
      _selectedLocation = latLng;
      _isLoadingLocation = false;
    });
  }

  void _confirm() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,

            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 14,

              onPositionChanged: (position, hasGesture) {
                setState(() {
                  _selectedLocation = position.center;
                });
              },
            ),

            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.locora.app',
              ),
            ],
          ),

          // Top AppBar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                children: [
                  Material(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 4,

                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(context),

                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Material(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      elevation: 4,

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),

                        child: Text(
                          "Pick Location",
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center Pin
          Center(
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FIcons.locate,
                    size: 46,
                    color: theme.colorScheme.primary,
                  ),

                  Container(
                    width: 4,
                    height: 14,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,

            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              elevation: 10,

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Selected Coordinates",
                      style: theme.textTheme.titleMedium,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${_selectedLocation.latitude.toStringAsFixed(6)}, "
                      "${_selectedLocation.longitude.toStringAsFixed(6)}",
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoadingLocation
                                ? null
                                : _goToCurrentLocation,

                            icon: _isLoadingLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location),

                            label: const Text("My Location"),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: FilledButton(
                            onPressed: _confirm,
                            child: const Text("Confirm"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
