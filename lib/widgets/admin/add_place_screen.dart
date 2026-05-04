import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/utils/cloudinary_config.dart';
import 'package:locora/utils/themes.dart';
import 'package:flutter/foundation.dart';

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
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();
  final mapsController = TextEditingController();
  double rating = 4.0;
  String city = "Karachi";
  String category = "Attraction";
  File? _selectedImage;
  bool _isUploading = false;

  final categories = ["Attraction", "Restaurant", "Hotel", "Event"];

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      final data = widget.existingData;

      titleController.text = data['title'];
      category = data['city'];
      descriptionController.text = data['description'];
      imageController.text = data['imageUrl'];
      mapsController.text = data['googleMapsLink'];
      rating = data['rating'];
      category = data['category'];
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isUploading = true;
        });

        final cldRes = await CloudinaryConfig.cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedFile.path, folder: 'my_folder'),
        );
        final imageUrl = cldRes.secureUrl;
        setState(() {
          imageController.text = imageUrl;
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Image uploaded successfully!'),
              backgroundColor: AppTheme.light.colorScheme.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppTheme.light.colorScheme.error,
          ),
        );
      }
      debugPrint('Image upload error: $e');
    }
  }

  void savePlace() async {
    if (!_formKey.currentState!.validate()) return;

    if (imageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload an image'),
          backgroundColor: AppTheme.light.colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final data = {
        'title': titleController.text,
        'city': city,
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

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving place: $e'),
            backgroundColor: AppTheme.light.colorScheme.error,
          ),
        );
      }
      debugPrint('Save error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? "Add Place" : "Edit Place"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.light.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                      AppTheme.light.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Uploading...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Place Image',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppTheme.light.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            if (_selectedImage != null ||
                                imageController.text.isNotEmpty)
                              Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _selectedImage != null
                                        ? kIsWeb
                                              ? Image.network(
                                                  _selectedImage!
                                                      .path, // Web uses blob URL
                                                  height: 200,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  _selectedImage!,
                                                  height: 200,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                )
                                        : Image.network(
                                            imageController.text,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              )
                            else
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: AppTheme
                                      .light
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.light.colorScheme.primary,
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 48,
                                        color:
                                            AppTheme.light.colorScheme.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No image selected',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _pickAndUploadImage,
                                icon: const Icon(Icons.cloud_upload),
                                label: const Text('Upload from Gallery'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.light.colorScheme.secondary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Basic Information Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basic Information',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppTheme.light.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: "Place Title",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: AppTheme.light.colorScheme.primary,
                                ),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? "Title is required" : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField(
                              onChanged: (c) => setState(() => city = c!),
                              initialValue: city,
                              items: pakistaniCities
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.name,
                                      child: Text(c.name),
                                    ),
                                  )
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: "City",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(
                                  Icons.location_city,
                                  color: AppTheme.light.colorScheme.primary,
                                ),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? "City is required" : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField(
                              initialValue: category,
                              items: categories
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => category = v!),
                              decoration: InputDecoration(
                                labelText: "Category",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(
                                  Icons.category,
                                  color: AppTheme.light.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Description Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Details',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppTheme.light.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Icon(
                                    Icons.description,
                                    color: AppTheme.light.colorScheme.primary,
                                  ),
                                ),
                                alignLabelWithHint: true,
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? "Description is required" : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: mapsController,
                              decoration: InputDecoration(
                                labelText: "Google Maps Link",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(
                                  Icons.map,
                                  color: AppTheme.light.colorScheme.primary,
                                ),
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? "Maps link is required" : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Rating Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rating',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color:
                                            AppTheme.light.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme
                                        .light
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color:
                                            AppTheme.light.colorScheme.tertiary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Slider(
                              value: rating,
                              min: 1,
                              max: 5,
                              divisions: 8,
                              activeColor: AppTheme.light.colorScheme.tertiary,
                              onChanged: (v) => setState(() => rating = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: AppTheme.light.colorScheme.error,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppTheme.light.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: savePlace,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Save Place'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.light.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
