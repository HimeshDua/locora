import 'package:flutter/material.dart';
import 'package:locora/screens/city/city_details.dart';

class DetailScreen extends StatelessWidget {
  final Place place;

  const DetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(place.image),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(place.rating.toString()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(place.description),

                  const SizedBox(height: 20),

                  const Text("Opening Hours: 9 AM - 11 PM"),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("View on Map"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
