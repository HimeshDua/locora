import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:locora/types/index.dart';

class MapTab extends StatefulWidget {
  final List<Place> places;

  const MapTab({super.key, required this.places});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  GoogleMapController? _controller;
  Position? _currentPosition;
  MapType _mapType = MapType.normal;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadMarkers();
  }

  @override
  void didUpdateWidget(covariant MapTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.places != widget.places) {
      _loadMarkers();
    }
  }

  // 📍 Get user location
  Future<void> _initLocation() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = pos);
  }

  // 📌 Convert places → markers
  void _loadMarkers() {
    final markers = widget.places
        .map((place) {
          if (place.lat == null ||
              place.lng == null ||
              place.lat == 0 ||
              place.lng == 0) {
            return null;
          }

          return Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.lat!, place.lng!),
            infoWindow: InfoWindow(
              title: place.title,
              snippet: place.category,
              onTap: () => _openPlaceDetails(place),
            ),
          );
        })
        .whereType<Marker>()
        .toSet();

    setState(() => _markers = markers);
  }

  Future<void> _fitBounds() async {
    if (_markers.isEmpty || _controller == null) return;

    final bounds = _createBounds(_markers);

    await _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  LatLngBounds _createBounds(Set<Marker> markers) {
    final lats = markers.map((m) => m.position.latitude);
    final lngs = markers.map((m) => m.position.longitude);

    return LatLngBounds(
      southwest: LatLng(
        lats.reduce((a, b) => a < b ? a : b),
        lngs.reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        lats.reduce((a, b) => a > b ? a : b),
        lngs.reduce((a, b) => a > b ? a : b),
      ),
    );
  }

  // 📍 Recenter map to user
  void _recenter() {
    if (_currentPosition == null || _controller == null) return;

    _controller!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 14,
        ),
      ),
    );
  }

  // 🛰️ Toggle map type
  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  // 📄 Open details
  void _openPlaceDetails(Place place) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                place.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // navigate to detail screen
                },
                child: const Text("View Details"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(24.8607, 67.0011),
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _controller = controller;
              _fitBounds();
            },
            myLocationEnabled: true,
            markers: _markers,
            mapType: _mapType,
          ),

          // Controls
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                _mapButton(Icons.my_location, _recenter),
                const SizedBox(height: 10),
                _mapButton(Icons.layers, _toggleMapType),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}
