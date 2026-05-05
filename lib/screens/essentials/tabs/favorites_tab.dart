import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:locora/types/index.dart';
import 'package:locora/widgets/favorites/card.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  User? user;
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites"), centerTitle: true),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('favorites')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading favorites"));
          }

          final favDocs = snapshot.data?.docs ?? [];

          if (favDocs.isEmpty) {
            return _emptyState(theme);
          }

          final favorites = favDocs
              .map((e) => FavoritePlace.fromFirestore(e))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(12),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return FavoritePlaceCard(fav: favorites[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text("No favorites yet", style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            "Start exploring and save places you love",
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
