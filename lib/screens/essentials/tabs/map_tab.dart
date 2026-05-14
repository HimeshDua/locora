import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forui/forui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/types/index.dart';
import 'package:url_launcher/url_launcher.dart';

class MapTab extends StatefulWidget {
  final List<Place> places;

  const MapTab({super.key, required this.places});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();

  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      _currentPosition = pos;
    });
  }

  Future<void> _openDirections(Place place) async {
    if (place.lat == null || place.lng == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _recenter() {
    if (_currentPosition == null) return;

    _mapController.move(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      14,
    );
  }

  void _openPlaceSheet(Place place) {
    final theme = FTheme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colors.background,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                place.title,
                style: theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                place.category,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                child: FButton(
                  onPress: () {
                    Navigator.pop(context);
                    _openDirections(place);
                  },

                  child: const Text('Get Directions'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,

        options: const MapOptions(
          initialCenter: LatLng(24.8607, 67.0011),
          initialZoom: 12,
        ),

        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

            userAgentPackageName: 'com.locora.app',
          ),

          MarkerLayer(
            markers: [
              ...widget.places
                  .where(
                    (place) =>
                        place.lat != null &&
                        place.lng != null &&
                        place.lat != 0 &&
                        place.lng != 0,
                  )
                  .map((place) {
                    return Marker(
                      point: LatLng(place.lat!, place.lng!),

                      width: 70,
                      height: 70,

                      child: GestureDetector(
                        onTap: () => _openPlaceSheet(place),

                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black.withValues(alpha: 0.18),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            FIcons.mapPin,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        // child: const Icon(
                        //   Icons.location_on,
                        //   color: Colors.red,
                        //   size: 38,
                        // ),
                      ),
                    );
                  }),

              if (_currentPosition != null)
                Marker(
                  point: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),

                  width: 60,
                  height: 60,

                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
            ],
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),

        child: FloatingActionButton(
          onPressed: _recenter,

          child: const Icon(FIcons.locate),
        ),
      ),
    );
  }
}
