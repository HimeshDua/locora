import 'package:flutter/material.dart';
import 'package:locora/screens/city/detailed_attraction_card.dart';
import 'package:locora/data/intrests.dart';
import 'package:locora/types/index.dart';

class CityDetailScreen extends StatelessWidget {
  final City city;

  const CityDetailScreen({super.key, required this.city});

  static final List<Place> places = pakistaniCityAttractions;

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = places
        .where((p) => p.city.toLowerCase().contains(city.name.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(city.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search places...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip("Attractions"),
                _chip("Restaurants"),
                _chip("Hotels"),
                _chip("Events"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // LISTINGS
          Expanded(
            child: ListView.builder(
              itemCount: filteredPlaces.length,
              itemBuilder: (_, i) {
                final place = filteredPlaces[i];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailAttractionScreen(place: place),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            place.imageUrl,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, object, stackTrace) {
                              return const Icon(Icons.error);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),

                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber),
                                  Text(place.rating.toString()),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Text(place.description),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Chip(label: Text(label)),
    );
  }
}
