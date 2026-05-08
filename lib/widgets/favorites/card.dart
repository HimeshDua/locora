import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/screens/city/detailed_attraction_card.dart';
import 'package:locora/types/index.dart';

class FavoritePlaceCard extends StatelessWidget {
  final FavoritePlace fav;

  const FavoritePlaceCard({super.key, required this.fav});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Place place = Place(
      id: fav.placeId,
      category: fav.category,
      title: fav.title,
      city: fav.city,
      description: fav.description,
      rating: fav.rating,
      googleMapsLink: fav.googleMapsLink,
      imageUrl: fav.imageUrl,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailAttractionScreen(place: place),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: place.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: _glassIcon(
                  HugeIcons.strokeRoundedFavourite,
                  color: Colors.red,
                ),
              ),

              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedStar,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Saved",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
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
      ),
    );
  }

  Widget _glassIcon(List<List<dynamic>> icon, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
      child: HugeIcon(icon: icon, size: 18, color: color),
    );
  }
}
