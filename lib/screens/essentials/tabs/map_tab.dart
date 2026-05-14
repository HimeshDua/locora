import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forui/forui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/types/index.dart';
import 'package:locora/widgets/map/map_tiles.dart';
import 'package:url_launcher/url_launcher.dart';

class MapTab extends StatefulWidget {
  final City city;
  final List<Place> places;

  const MapTab({super.key, required this.city, required this.places});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();

  Position? _currentPosition;
  bool _isLocating = false;
  bool _locationDenied = false;

  List<Place> get _mappedPlaces => widget.places
      .where(
        (place) =>
            place.lat != null &&
            place.lng != null &&
            place.lat != 0 &&
            place.lng != 0,
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() => _isLocating = true);

    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _locationDenied = true;
      });
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition();

      if (!mounted) return;
      setState(() {
        _currentPosition = pos;
        _isLocating = false;
        _locationDenied = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLocating = false);
    }
  }

  Future<void> _openDirections(Place place) async {
    if (place.lat == null || place.lng == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _recenter() {
    if (_currentPosition == null) {
      _initLocation();
      return;
    }

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
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            MediaQuery.of(context).padding.bottom + 20,
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _markerColor(place).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FIcons.mapPin,
                      color: _markerColor(place),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.title,
                          style: theme.typography.lg.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${place.category} in ${place.city}',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _MapInfoChip(
                    icon: Icons.star,
                    label: place.rating.toStringAsFixed(1),
                    color: Colors.amber,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _MapInfoChip(
                    icon: FIcons.navigation,
                    label: 'Directions ready',
                    theme: theme,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                place.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  height: 1.5,
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

  Color _markerColor(Place place) {
    switch (place.category.toLowerCase()) {
      case 'restaurant':
        return const Color(0xFFEF4444);
      case 'hotel':
        return const Color(0xFF2563EB);
      case 'event':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFF059669);
    }
  }

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + delta);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final mappedPlaces = _mappedPlaces;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(24.8607, 67.0011),
              initialZoom: 12,
              minZoom: 4,
              maxZoom: 18,
            ),
            children: [
              locoraEnglishTileLayer(context),
              MarkerLayer(
                markers: [
                  ...mappedPlaces.map((place) {
                    final color = _markerColor(place);

                    return Marker(
                      point: LatLng(place.lat!, place.lng!),
                      width: 54,
                      height: 64,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _openPlaceSheet(place),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                    color: Colors.black.withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                FIcons.mapPin,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 54,
                      height: 54,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF2563EB,
                          ).withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const LocoraMapAttribution(),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _MapHeader(
                cityName: widget.city.name,
                mappedCount: mappedPlaces.length,
                totalCount: widget.places.length,
                theme: theme,
              ),
            ),
          ),
          if (mappedPlaces.isEmpty)
            Align(
              alignment: Alignment.center,
              child: _EmptyMapCard(cityName: widget.city.name, theme: theme),
            ),
          Positioned(
            right: 16,
            bottom: 112,
            child: _MapControls(
              isLocating: _isLocating,
              locationDenied: _locationDenied,
              onLocate: _recenter,
              onZoomIn: () => _zoomBy(1),
              onZoomOut: () => _zoomBy(-1),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  final String cityName;
  final int mappedCount;
  final int totalCount;
  final FThemeData theme;

  const _MapHeader({
    required this.cityName,
    required this.mappedCount,
    required this.totalCount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final hiddenCount = totalCount - mappedCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: theme.colors.background.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(FIcons.map, color: theme.colors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cityName,
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hiddenCount > 0
                      ? '$mappedCount mapped, $hiddenCount missing coordinates'
                      : '$mappedCount places mapped',
                  style: theme.typography.xs.copyWith(
                    color: theme.colors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  final bool isLocating;
  final bool locationDenied;
  final VoidCallback onLocate;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final FThemeData theme;

  const _MapControls({
    required this.isLocating,
    required this.locationDenied,
    required this.onLocate,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapControlButton(icon: FIcons.plus, onTap: onZoomIn, theme: theme),
        const SizedBox(height: 8),
        _MapControlButton(icon: FIcons.minus, onTap: onZoomOut, theme: theme),
        const SizedBox(height: 8),
        _MapControlButton(
          icon: locationDenied ? FIcons.locateOff : FIcons.locate,
          onTap: onLocate,
          theme: theme,
          child: isLocating
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colors.foreground,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final FThemeData theme;
  final Widget? child;

  const _MapControlButton({
    required this.icon,
    required this.onTap,
    required this.theme,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colors.background.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(14),
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colors.border, width: 0.8),
          ),
          child: child ?? Icon(icon, size: 19, color: theme.colors.foreground),
        ),
      ),
    );
  }
}

class _MapInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final FThemeData theme;

  const _MapInfoChip({
    required this.icon,
    required this.label,
    required this.theme,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? theme.colors.mutedForeground),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.typography.xs.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMapCard extends StatelessWidget {
  final String cityName;
  final FThemeData theme;

  const _EmptyMapCard({required this.cityName, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colors.background.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colors.border, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FIcons.mapPinOff, color: theme.colors.mutedForeground, size: 28),
          const SizedBox(height: 10),
          Text(
            'No mapped places yet',
            style: theme.typography.sm.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add coordinates to places in $cityName to show them here.',
            textAlign: TextAlign.center,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
