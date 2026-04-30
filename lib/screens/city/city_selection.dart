import 'package:flutter/material.dart';
import 'package:locora/screens/city/city_details.dart';

class City {
  final String name;
  final String image;
  final String description;

  City({required this.name, required this.image, required this.description});
}

class CitySelectionScreen extends StatelessWidget {
  const CitySelectionScreen({super.key});

  static final List<City> cities = [
    City(
      name: "Karachi",
      image: "https://images.unsplash.com/photo-1580655653885-65763b2597d0",
      description: "City of lights",
    ),
    City(
      name: "Lahore",
      image: "https://images.unsplash.com/photo-1609947017136-9daf32a5eb16",
      description: "Cultural capital",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Explore Cities")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: cities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (_, i) {
            final city = cities[i];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CityDetailScreen(city: city),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(city.image, fit: BoxFit.cover),
                    ),

                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black54],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          Text(
                            city.description,
                            style: const TextStyle(color: Colors.white70),
                          ),
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
    );
  }
}
