import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? selectedLocation;
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.initialLat != null && widget.initialLng != null) {
      selectedLocation = LatLng(widget.initialLat!, widget.initialLng!);
    }
  }

  void _onTap(LatLng pos) {
    setState(() => selectedLocation = pos);
  }

  void _confirm() {
    if (selectedLocation != null) {
      Navigator.pop(context, selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLocation ?? const LatLng(24.8607, 67.0011),
              zoom: 14,
            ),
            onTap: _onTap,
            onMapCreated: (c) => _controller = c,
            markers: selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: selectedLocation!,
                    ),
                  },
            myLocationEnabled: true,
          ),

          // Floating confirm button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: selectedLocation == null ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Confirm Location"),
            ),
          ),
        ],
      ),
    );
  }
}
