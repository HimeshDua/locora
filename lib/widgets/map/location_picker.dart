import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:forui/forui.dart';
import 'package:locora/widgets/map/map_tiles.dart';

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
  bool _locationDenied = false;

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

    try {
      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _isLoadingLocation = false;
          _locationDenied = true;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      final latLng = LatLng(position.latitude, position.longitude);

      _mapController.move(latLng, 16);

      if (!mounted) return;
      setState(() {
        _selectedLocation = latLng;
        _isLoadingLocation = false;
        _locationDenied = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingLocation = false);
    }
  }

  void _confirm() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final theme = FTheme.of(context);

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
              locoraEnglishTileLayer(context),
              const LocoraMapAttribution(),
            ],
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                children: [
                  Material(
                    color: theme.colors.background.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(14),
                    elevation: 4,

                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(context),

                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_back,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Material(
                      color: theme.colors.background.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(14),
                      elevation: 4,

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pick Location',
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.foreground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Drag the map to place the pin',
                              style: theme.typography.xs.copyWith(
                                color: theme.colors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: theme.colors.primary,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2.4),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                          color: Colors.black.withValues(alpha: 0.22),
                        ),
                      ],
                    ),
                    child: const Icon(
                      FIcons.mapPin,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),

                  Container(
                    width: 4,
                    height: 14,
                    decoration: BoxDecoration(
                      color: theme.colors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,

            child: Material(
              color: theme.colors.background.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(18),
              elevation: 10,

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Selected Coordinates',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.muted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_selectedLocation.latitude.toStringAsFixed(6)}, '
                        '${_selectedLocation.longitude.toStringAsFixed(6)}',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (_locationDenied) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Location access is off. You can still drag the map to choose a point.',
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          height: 1.4,
                        ),
                      ),
                    ],

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
                                : Icon(
                                    _locationDenied
                                        ? FIcons.locateOff
                                        : FIcons.locate,
                                  ),
                            label: const Text('My Location'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  materialTheme.colorScheme.onSurface,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: FButton(
                            variant: .primary,
                            onPress: _confirm,
                            child: const Text('Confirm'),
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
