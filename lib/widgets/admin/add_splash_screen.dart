import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPlaceScreen extends StatefulWidget {
  final String? docId;
  final dynamic existingData;

  const AddPlaceScreen({super.key, this.docId, this.existingData});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final cityController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();
  final mapsController = TextEditingController();
  double rating = 4.0;
  String category = "Attraction";

  final categories = ["Attraction", "Restaurant", "Hotel", "Event"];

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      final data = widget.existingData;

      titleController.text = data['title'];
      cityController.text = data['city'];
      descriptionController.text = data['description'];
      imageController.text = data['imageUrl'];
      mapsController.text = data['googleMapsLink'];
      rating = data['rating'];
      category = data['category'];
    }
  }

  void savePlace() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'title': titleController.text,
      'city': cityController.text,
      'description': descriptionController.text,
      'imageUrl': imageController.text,
      'googleMapsLink': mapsController.text,
      'rating': rating,
      'category': category,
    };

    final ref = FirebaseFirestore.instance.collection('places');

    if (widget.docId == null) {
      await ref.add(data);
    } else {
      await ref.doc(widget.docId).update(data);
    }

    if (context.mounted) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? "Add Place" : "Edit Place"),
        backgroundColor: theme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "City"),
              ),
              DropdownButtonFormField(
                initialValue: category,
                items: categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
              TextFormField(
                controller: mapsController,
                decoration: const InputDecoration(
                  labelText: "Google Maps Link",
                ),
              ),
              const SizedBox(height: 10),
              Text("Rating: ${rating.toStringAsFixed(1)}"),
              Slider(
                value: rating,
                min: 1,
                max: 5,
                onChanged: (v) => setState(() => rating = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: savePlace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                ),
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
