import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:forui/forui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:locora/types/index.dart';

class MapTab extends StatefulWidget {
  final List<Place> places;

  const MapTab({super.key, required this.places});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _mapController = MapController();

  Position? _currentPosition;
  List<LatLng> _routePoints = [];

  final String orsApiKey = dotenv.env['OPEN_ROUTER_MAP_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (orsApiKey.isEmpty) {
      debugPrint("ORS API KEY MISSING");
      return;
    }

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

  Future<void> _getRoute(Place place) async {
    if (_currentPosition == null) return;

    final start =
        '${_currentPosition!.longitude},${_currentPosition!.latitude}';

    final end = '${place.lng},${place.lat}';

    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car'
        '?api_key=$orsApiKey'
        '&start=$start'
        '&end=$end';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['features'] == null || data['features'].isEmpty) {
        return;
      }

      final coords = data['features'][0]['geometry']['coordinates'] as List;

      final points = coords.map((c) {
        return LatLng(c[1], c[0]);
      }).toList();

      setState(() {
        _routePoints = points;
      });
    }
  }

  void _recenter() {
    if (_currentPosition == null) return;

    _mapController.move(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      14,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(24.8607, 67.0011),
          initialZoom: 16,
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
                      width: 80,
                      height: 80,

                      child: GestureDetector(
                        onTap: () {
                          _getRoute(place);
                        },

                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.red,
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
                  width: 60,
                  height: 60,

                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
            ],
          ),

          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [Polyline(points: _routePoints, strokeWidth: 5)],
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
