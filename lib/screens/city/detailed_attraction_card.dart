// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/firebase/actions.dart';

class DetailAttractionScreen extends StatefulWidget {
  final Place place;

  const DetailAttractionScreen({super.key, required this.place});

  @override
  State<DetailAttractionScreen> createState() => _DetailAttractionScreenState();
}

class _DetailAttractionScreenState extends State<DetailAttractionScreen> {
  final TextEditingController _controller = TextEditingController();

  double _selectedRating = 4;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _addReview() async {
    final text = _controller.text.trim();
    if (text.isEmpty || user?.displayName == null) return;

    _controller.clear();

    await addReview(
      placeId: widget.place.id,
      userName: user!.displayName!,
      comment: text,
      rating: _selectedRating,
    );
  }

  Future<void> _toggleFavorite(bool isFav) async {
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(widget.place.id);

    if (isFav) {
      await ref.delete();
    } else {
      final p = widget.place;

      final fav = FavoritePlace(
        userId: user!.uid,

        placeId: p.id,
        title: p.title,
        imageUrl: p.imageUrl,
        category: p.category,
        city: p.city,
        description: p.description,
        rating: p.rating,
        googleMapsLink: p.googleMapsLink,
      );

      await ref.set(fav.toFirestore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(place),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderInfo(place, theme),
                      const SizedBox(height: 20),
                      _buildDescription(place, theme),
                      const SizedBox(height: 24),
                      _buildReviews(place),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),

          _buildBottomInput(theme),
        ],
      ),
    );
  }

  // 🔥 COLLAPSING HEADER
  Widget _buildAppBar(Place place) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.black,
      leading: _glassBtn(
        HugeIcons.strokeRoundedArrowLeft01,
        () => Navigator.pop(context),
      ),
      actions: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .collection('favorites')
              .doc(place.id)
              .snapshots(),
          builder: (_, snap) {
            final isFav = snap.data?.exists ?? false;

            return Row(
              children: [
                _glassBtn(
                  isFav
                      ? HugeIcons.strokeRoundedFavourite
                      : HugeIcons.strokeRoundedFavourite,
                  () => _toggleFavorite(isFav),
                  color: isFav ? Colors.red : Colors.white,
                  isFav: isFav,
                ),
                const SizedBox(width: 10),
                _glassBtn(HugeIcons.strokeRoundedMaps, () {}),
                const SizedBox(width: 10),
              ],
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(place.imageUrl, fit: BoxFit.cover),

            // gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 HEADER INFO
  Widget _buildHeaderInfo(Place place, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          place.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          place.city,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedStar,
              size: 18,
              color: Colors.amber,
            ),
            const SizedBox(width: 6),
            Text(place.rating.toStringAsFixed(1)),
            const SizedBox(width: 12),
            _chip(place.category, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(Place place, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("About", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          place.description,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }

  // 🔥 REVIEWS
  Widget _buildReviews(Place place) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reviews", style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),

        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('reviews')
              .where('placeId', isEqualTo: place.id)
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final reviews = snapshot.data!.docs
                .map((e) => Review.fromFirestore(e))
                .toList();

            if (reviews.isEmpty) {
              return const Text("No reviews yet.");
            }

            return Column(
              children: reviews
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _reviewCard(r),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _reviewCard(Review r) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(child: Text(r.userName[0])),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.userName, style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    r.rating.toInt(),
                    (i) => HugeIcon(
                      icon: HugeIcons.strokeRoundedStar,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(r.comment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 BOTTOM INPUT
  Widget _buildBottomInput(ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedStar,
                    color: star <= _selectedRating ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _selectedRating = star.toDouble()),
                );
              }),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Write a review...",
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedNavigation03,
                      color: Colors.white,
                    ),
                    onPressed: _addReview,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }

  Widget _glassBtn(
    List<List<dynamic>> icon,
    VoidCallback onTap, {
    Color color = Colors.white,
    bool isFav = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isFav
              ? Colors.red.withOpacity(0.6)
              : Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: HugeIcon(icon: icon, color: color),
      ),
    );
  }
}
