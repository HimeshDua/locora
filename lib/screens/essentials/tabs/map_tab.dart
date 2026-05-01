import 'package:flutter/material.dart';
import 'package:locora/types/index.dart';

class MapTab extends StatelessWidget {
  final City city;

  const MapTab({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Map")),
      body: const Center(child: Text("Google Map will be here")),
    );
  }
}
