import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/types/index.dart';
import 'package:locora/widgets/favorites/card.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final user = FirebaseAuth.instance.currentUser;

  late final favRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .collection('favorites')
      .orderBy('addedAt', descending: true)
      .limit(50);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (user == null) {
      return _emptyState(theme, "Login to see your favorites");
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: favRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _loadingGrid();
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading favorites"));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return _emptyState(theme, "Start saving places you love");
                  }

                  final favorites = docs
                      .map((e) => FavoritePlace.fromFirestore(e))
                      .toList();

                  return _buildGrid(favorites);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedFavourite,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            "Saved Places",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildGrid(List<FavoritePlace> favorites) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      itemCount: favorites.length,
      itemBuilder: (_, i) {
        return FavoritePlaceCard(fav: favorites[i]);
      },
    );
  }

  Widget _loadingGrid() {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      itemCount: 6,
      itemBuilder: (_, _) {
        return Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _emptyState(ThemeData theme, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedFavourite,
            size: 60,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(text, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            "Explore and tap ❤️ to save places",
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
