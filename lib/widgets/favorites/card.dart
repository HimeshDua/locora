import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:locora/screens/city/detailed_attraction_card.dart';
import 'package:locora/types/index.dart';

class FavoritePlaceCard extends StatelessWidget {
  final FavoritePlace fav;

  const FavoritePlaceCard({super.key, required this.fav});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('places')
          .doc(fav.placeId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _cardSkeleton(theme);
        }

        final place = Place.fromFirestore(snapshot.data!);

        return Material(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailAttractionScreen(place: place),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imageSection(place, theme),
                _infoSection(place, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imageSection(Place place, ThemeData theme) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: place.imageUrl,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // Gradient overlay
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Category chip
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                place.category,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(Place place, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 16,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 4),
              Text(
                place.rating.toStringAsFixed(1),
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            place.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSkeleton(ThemeData theme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
