import 'package:flutter/material.dart';
import 'package:locora/screens/essentials/tabs/map_tab.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/firebase/actions.dart';

class MapTabWrapper extends StatelessWidget {
  final City city;

  const MapTabWrapper({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Place>>(
      future: fetchPlacesByCity(city.name),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return MapTab(places: snapshot.data!);
      },
    );
  }
}
