import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/types/index.dart';
import 'package:locora/widgets/map/location_picker.dart';
import 'package:locora/utils/cloudinary_config.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class AddPlaceSheet extends StatefulWidget {
  final String? docId;
  final Place? existingData;

  const AddPlaceSheet({super.key, this.docId, this.existingData});

  @override
  State<AddPlaceSheet> createState() => _AddPlaceSheetState();
}

class _AddPlaceSheetState extends State<AddPlaceSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController title;
  late final TextEditingController description;

  String city = "Karachi";
  String category = "Attraction";
  double rating = 4.0;

  String imageUrl = "";
  bool uploading = false;

  double? lat;
  double? lng;

  final categories = ["Attraction", "Restaurant", "Hotel", "Event"];

  @override
  void initState() {
    super.initState();
    final d = widget.existingData;
    title = TextEditingController(text: d?.title ?? "");
    description = TextEditingController(text: d?.description ?? "");

    if (d != null) {
      city = d.city;
      category = d.category;
      rating = d.rating;
      imageUrl = d.imageUrl;
      lat = d.lat;
      lng = d.lng;
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return;

    setState(() => uploading = true);
    try {
      final res = await CloudinaryConfig.cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, folder: 'places'),
      );
      setState(() => imageUrl = res.secureUrl);
    } catch (e) {
      _showToast("Upload failed. Try again.");
    } finally {
      setState(() => uploading = false);
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;
    if (imageUrl.isEmpty) {
      _showToast("Please upload an image first");
      return;
    }

    final data = {
      'title': title.text.trim(),
      'description': description.text.trim(),
      'city': city,
      'category': category,
      'rating': rating,
      'imageUrl': imageUrl,
      'lat': lat,
      'lng': lng,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      final ref = FirebaseFirestore.instance.collection('places');
      if (widget.docId == null) {
        await ref.add(data);
      } else {
        await ref.doc(widget.docId).update(data);
      }
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showToast("Error saving data");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _imageSection(theme),
                    const SizedBox(height: 32),
                    _sectionLabel(theme, "Place Details"),
                    _input(
                      controller: title,
                      label: "Place Title",
                      icon: HugeIcons.strokeRoundedLocation01,
                    ),
                    const SizedBox(height: 16),
                    _input(
                      controller: description,
                      label: "Description",
                      icon: HugeIcons.strokeRoundedNote01,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel(theme, "Categorization"),
                    Row(
                      children: [
                        Expanded(child: _dropdownCity(theme)),
                        const SizedBox(width: 12),
                        Expanded(child: _dropdownCategory(theme)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _sectionLabel(theme, "Location on Map"),
                    _locationPicker(theme),
                    const SizedBox(height: 32),
                    _sectionLabel(theme, "Platform Rating"),
                    _ratingSlider(theme),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
          _buildActionBar(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            widget.docId == null ? "New Destination" : "Update Destination",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _imageSection(ThemeData theme) {
    return GestureDetector(
      onTap: uploading ? null : pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              if (imageUrl.isEmpty && !uploading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedImageAdd01,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text("Add Photo", style: theme.textTheme.labelLarge),
                    ],
                  ),
                ),
              if (uploading)
                const Center(child: CircularProgressIndicator.adaptive()),
              if (imageUrl.isNotEmpty && !uploading)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 18,
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit03,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REFACTORED INPUT FIELD ---
  Widget _input({
    required TextEditingController controller,
    required String label,
    required List<List<dynamic>> icon,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: HugeIcon(
            icon: icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      validator: (v) => v!.isEmpty ? "Cannot be empty" : null,
    );
  }

  Widget _dropdownCity(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: city,
      items: pakistaniCities
          .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
          .toList(),
      onChanged: (v) => setState(() => city = v!),
      decoration: _dropdownDecoration(
        theme,
        "City",
        HugeIcons.strokeRoundedCity03,
      ),
    );
  }

  Widget _dropdownCategory(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: category,
      items: categories
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => setState(() => category = v!),
      decoration: _dropdownDecoration(
        theme,
        "Type",
        HugeIcons.strokeRoundedListIndentIncrease,
      ),
    );
  }

  InputDecoration _dropdownDecoration(
    ThemeData theme,
    String label,
    List<List<dynamic>> icon,
  ) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: HugeIcon(icon: icon, size: 20, color: theme.colorScheme.primary),
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _locationPicker(ThemeData theme) {
    return GestureDetector(
      onTap: _openMapPicker,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surfaceContainerLow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: lat == null
              ? const Center(child: Text("Tap to select location"))
              : IgnorePointer(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat!, lng!),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("sel"),
                        position: LatLng(lat!, lng!),
                      ),
                    },
                    zoomControlsEnabled: false,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _openMapPicker() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initialLat: lat, initialLng: lng),
      ),
    );
    if (res != null && res is LatLng) {
      setState(() {
        lat = res.latitude;
        lng = res.longitude;
      });
    }
  }

  Widget _ratingSlider(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedAward01,
            color: Colors.amber.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          Expanded(
            child: Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 40,
              onChanged: (v) => setState(() => rating = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Discard"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: uploading ? null : save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(widget.docId == null ? "Create" : "Save Changes"),
            ),
          ),
        ],
      ),
    );
  }
}
