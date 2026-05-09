import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/types/index.dart';
import 'package:locora/widgets/elements/section_label.dart';
import 'package:locora/widgets/map/location_picker.dart';
import 'package:locora/utils/cloudinary_config.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:locora/widgets/reviews/rating_card.dart';
import 'package:locora/widgets/reviews/review_section.dart';

class AddOrEditPlaceSheet extends StatefulWidget {
  final String? docId;
  final Place? existingData;

  const AddOrEditPlaceSheet({super.key, this.docId, this.existingData});

  @override
  State<AddOrEditPlaceSheet> createState() => _AddOrEditPlaceSheetState();
}

class _AddOrEditPlaceSheetState extends State<AddOrEditPlaceSheet> {
  final _formKey = GlobalKey<FormState>();
  String? get placeId => widget.docId;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  String _city = 'Karachi';
  String _category = 'Attraction';
  double _rating = 4.0;
  String _imageUrl = '';
  bool _uploading = false;
  double? _lat;
  double? _lng;

  final _categories = ['Attraction', 'Restaurant', 'Hotel', 'Event'];

  @override
  void initState() {
    super.initState();
    final d = widget.existingData;
    _titleCtrl = TextEditingController(text: d?.title ?? '');
    _descCtrl = TextEditingController(text: d?.description ?? '');
    if (d != null) {
      _city = d.city;
      _category = d.category;
      _rating = d.rating;
      _imageUrl = d.imageUrl;
      _lat = d.lat;
      _lng = d.lng;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final res = await CloudinaryConfig.cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, folder: 'places'),
      );
      setState(() => _imageUrl = res.secureUrl);
    } catch (_) {
      _toast('Upload failed. Try again.');
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _openMapPicker() async {
    final res = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LocationPickerScreen(initialLat: _lat, initialLng: _lng),
      ),
    );
    if (res != null) {
      setState(() {
        _lat = res.latitude;
        _lng = res.longitude;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrl.isEmpty) {
      _toast('Please upload an image first');
      return;
    }

    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'city': _city,
      'category': _category,
      'rating': _rating,
      'imageUrl': _imageUrl,
      'lat': _lat,
      'lng': _lng,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      final ref = FirebaseFirestore.instance.collection('places');
      if (placeId == null) {
        await ref.add(data);
      } else {
        await ref.doc(placeId).update(data);
      }
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      _toast('Error saving data');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(theme),
          _buildSheetHeader(theme),
          Divider(height: 1, color: theme.colors.border),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(theme),
                    const SizedBox(height: 28),
                    SectionLabel(label: 'Place Details', theme: theme),
                    const SizedBox(height: 12),
                    _buildTitleField(),
                    const SizedBox(height: 12),
                    _buildDescriptionField(),
                    const SizedBox(height: 28),
                    SectionLabel(label: 'Categorization', theme: theme),
                    const SizedBox(height: 12),
                    _buildCategoryRow(theme),
                    const SizedBox(height: 28),
                    SectionLabel(label: 'Location', theme: theme),
                    const SizedBox(height: 12),
                    _buildLocationPicker(theme),
                    const SizedBox(height: 28),
                    SectionLabel(label: 'Rating', theme: theme),
                    if (placeId != null) ...[
                      const SizedBox(height: 28),
                      buildReviewsSection(theme, placeId!),
                    ],
                    const SizedBox(height: 12),
                    buildRatingCard(
                      theme,
                      _rating,
                      (r) => setState(() => _rating = r),
                    ),
                    const SizedBox(height: 8),
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

  Widget _buildHandle(FThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(FThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(
        children: [
          Text(
            placeId == null ? 'New Destination' : 'Update Destination',
            style: theme.typography.lg.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colors.foreground,
            ),
          ),
          const Spacer(),
          FButton.icon(
            onPress: () => Navigator.pop(context),
            child: Icon(
              FIcons.x,
              size: 15,
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(FThemeData theme) {
    return GestureDetector(
      onTap: _uploading ? null : _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colors.muted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colors.border, width: 0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_imageUrl.isNotEmpty)
                CachedNetworkImage(imageUrl: _imageUrl, fit: BoxFit.cover),

              if (_imageUrl.isNotEmpty)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black26],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

              if (_imageUrl.isEmpty && !_uploading)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colors.border,
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        FIcons.imagePlus,
                        size: 20,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap to add photo',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

              if (_uploading)
                Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colors.foreground,
                  ),
                ),

              if (_imageUrl.isNotEmpty && !_uploading)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FIcons.pencil, size: 13, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          'Change',
                          style: theme.typography.xs.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return FormField<String>(
      validator: (_) =>
          _titleCtrl.text.trim().isEmpty ? 'Title cannot be empty' : null,
      builder: (state) => FTextField(
        control: .managed(
          controller: _titleCtrl,
          onChange: (_) => state.didChange(_titleCtrl.text),
        ),
        label: const Text('Place Title'),
        hint: 'e.g. Clifton Beach',
        error: state.errorText != null ? Text(state.errorText!) : null,
      ),
    );
  }

  Widget _buildDescriptionField() {
    return FormField<String>(
      validator: (_) =>
          _descCtrl.text.trim().isEmpty ? 'Description cannot be empty' : null,
      builder: (state) => FTextField(
        control: .managed(
          controller: _descCtrl,
          onChange: (_) => state.didChange(_descCtrl.text),
        ),
        label: const Text('Description'),
        hint: 'Describe this place…',
        maxLines: 4,
        minLines: 3,
        error: state.errorText != null ? Text(state.errorText!) : null,
      ),
    );
  }

  Widget _buildCategoryRow(FThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            theme,
            'City',
            _city,
            pakistaniCities.map((c) => c.name).toList(),
            (v) => setState(() => _city = v!),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown(
            theme,
            'Type',
            _category,
            _categories,
            (v) => setState(() => _category = v!),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    FThemeData theme,
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colors.foreground,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colors.border, width: 0.9),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: theme.colors.background,
              style: theme.typography.sm.copyWith(
                color: theme.colors.foreground,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(
                FIcons.chevronsUpDown,
                size: 15,
                color: theme.colors.mutedForeground,
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPicker(FThemeData theme) {
    final hasLocation = _lat != null && _lng != null;

    return GestureDetector(
      onTap: _openMapPicker,
      child: Container(
        height: 140,
        //  height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colors.muted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colors.border, width: 0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: hasLocation
              ? Stack(
                  children: [
                    IgnorePointer(
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_lat!, _lng!),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('sel'),
                            position: LatLng(_lat!, _lng!),
                          ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FIcons.pencil, size: 13, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              'Change',
                              style: theme.typography.xs.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colors.border,
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        FIcons.mapPin,
                        size: 20,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap to select location',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Widget _buildRating(FThemeData theme) {
  //   return Container(
  //     padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
  //     decoration: BoxDecoration(
  //       color: theme.colors.muted,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: theme.colors.border, width: 0.8),
  //     ),
  //     child: Row(
  //       children: [
  //         const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
  //         const SizedBox(width: 8),
  //         SizedBox(
  //           width: 32,
  //           child: Text(
  //             _rating.toStringAsFixed(1),
  //             style: theme.typography.sm.copyWith(
  //               fontWeight: FontWeight.w700,
  //               color: theme.colors.foreground,
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: SliderTheme(
  //             data: SliderThemeData(
  //               trackHeight: 2,
  //               thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
  //               overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
  //               activeTrackColor: theme.colors.foreground,
  //               inactiveTrackColor: theme.colors.border,
  //               thumbColor: theme.colors.foreground,
  //               overlayColor: theme.colors.foreground.withValues(alpha: 0.12),
  //             ),
  //             child: Slider(
  //               value: _rating,
  //               min: 1,
  //               max: 5,
  //               divisions: 40,
  //               onChanged: (v) => setState(() => _rating = v),
  //             ),
  //           ),
  //         ),
  //         Text(
  //           '/ 5',
  //           style: theme.typography.xs.copyWith(
  //             color: theme.colors.mutedForeground,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildActionBar(FThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FButton(
              variant: .outline,
              onPress: () => Navigator.pop(context),
              child: const Text('Discard'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FButton(
              onPress: _uploading ? null : _save,
              child: Text(placeId == null ? 'Create' : 'Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
