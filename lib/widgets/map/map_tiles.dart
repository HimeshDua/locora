import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

const _cartoVoyagerEnglishTiles =
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

TileLayer locoraEnglishTileLayer(BuildContext context) {
  return TileLayer(
    urlTemplate: _cartoVoyagerEnglishTiles,
    subdomains: const ['a', 'b', 'c', 'd'],
    userAgentPackageName: 'com.locora.app',
    tileProvider: NetworkTileProvider(headers: const {'Accept-Language': 'en'}),
    retinaMode: RetinaMode.isHighDensity(context),
    tileDisplay: const TileDisplay.fadeIn(
      duration: Duration(milliseconds: 140),
    ),
  );
}

class LocoraMapAttribution extends StatelessWidget {
  const LocoraMapAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return const RichAttributionWidget(
      attributions: [
        TextSourceAttribution('CARTO'),
        TextSourceAttribution('OpenStreetMap contributors'),
      ],
    );
  }
}
