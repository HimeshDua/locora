import 'package:flutter/material.dart';
import 'package:locora/screens/city/detailed_city_card.dart';
import 'package:locora/screens/city/city_selection.dart';

class Place {
  final String city;
  final String name;
  final String image;
  final String description;
  final double rating;

  Place({
    required this.city,
    required this.name,
    required this.image,
    required this.description,
    required this.rating,
  });
}

class CityDetailScreen extends StatelessWidget {
  final City city;

  const CityDetailScreen({super.key, required this.city});

  static final List<Place> places = [
    Place(
      city: "Karachi",
      name: "Clifton Beach",
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
      description: "Beautiful beach in Karachi",
      rating: 4.5,
    ),
    Place(
      city: "Lahore",
      name: "Food Street",
      image: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5",
      description: "Best food experience",
      rating: 4.7,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = places
        .where((p) => p.city.contains(city.name))
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
                        builder: (_) => DetailScreen(place: place),
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
                            place.image,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
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
