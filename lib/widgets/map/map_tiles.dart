import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

const _cartoVoyagerEnglishTiles =
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
const _openStreetMapFallbackTiles =
    'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

TileLayer locoraEnglishTileLayer(BuildContext context) {
  return TileLayer(
    urlTemplate: _cartoVoyagerEnglishTiles,
    fallbackUrl: _openStreetMapFallbackTiles,
    subdomains: const ['a', 'b', 'c', 'd'],
    userAgentPackageName: 'com.locora.app',
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
