import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:locora/screens/city/detailed_attraction_card.dart';
import 'package:locora/types/index.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeTab extends StatefulWidget {
  final City? city;
  const HomeTab({super.key, required this.city});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String query = "";
  String selectedCategory = "All";

  final _categories = ['All', 'Attraction', 'Restaurant', 'Hotel', 'Event'];
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = widget.city;

    if (city == null || city.name.isEmpty) {
      return const Center(child: Text('City not found'));
    }

    final theme = FTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            _buildSearchBar(theme),
            _buildCategories(theme),
            Expanded(child: _buildPlaces(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(FIcons.mapPin, size: 15, color: theme.colors.foreground),
                  const SizedBox(width: 5),
                  Text(
                    widget.city!.name,
                    style: theme.typography.xl.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colors.foreground,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          FButton.icon(
            builder: FButton.defaultIconContentBuilder,
            onPress: () {},
            child: Icon(FIcons.bell),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(FThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: FTextField(
        hint: 'Search ${widget.city!.name}...',
        control: .managed(
          controller: _searchController,
          onChange: (v) => setState(() => query = v as String),
        ),
        prefixBuilder: (context, style, _) => Padding(
          padding: EdgeInsets.only(left: 4),
          child: Icon(
            FIcons.search,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(FThemeData theme) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = cat == selectedCategory;

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? theme.colors.foreground : theme.colors.muted,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? theme.colors.background
                      : theme.colors.mutedForeground,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaces(FThemeData theme) {
    final city = widget.city!;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('places')
          .where('city', isEqualTo: city.name)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colors.foreground,
            ),
          );
        }

        final docs = snap.data?.docs ?? [];
        final places = docs.map((e) => Place.fromFirestore(e)).where((p) {
          final matchesQuery = p.title.toLowerCase().contains(
            query.toLowerCase(),
          );
          final matchesCategory =
              selectedCategory == 'All' || p.category == selectedCategory;
          return matchesQuery && matchesCategory;
        }).toList();

        if (places.isEmpty) return _buildEmpty(theme);

        return MasonryGridView.count(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: places.length,
          itemBuilder: (_, i) => _buildCard(places[i], theme),
        );
      },
    );
  }

  Widget _buildCard(Place place, FThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailAttractionScreen(place: place)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Image
            CachedNetworkImage(
              imageUrl: place.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) =>
                  Container(height: 200, color: theme.colors.muted),
            ),

            // Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Category badge — top left
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  place.category,
                  style: theme.typography.xs.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            // Title + rating — bottom
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.sm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(FIcons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: theme.typography.xs.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(FThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FIcons.mapPinOff, size: 40, color: theme.colors.mutedForeground),
          const SizedBox(height: 12),
          Text(
            'No places found',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
