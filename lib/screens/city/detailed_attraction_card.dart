// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool isFavorite = false;
  var user = null as User?;

  void _addReview() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    String? userName = user?.displayName;
    if (text.isEmpty) return;
    if (userName == null) return;

    _controller.clear();

    try {
      await addReview(
        placeId: widget.place.id,
        userName: userName,
        comment: text,
        rating: _selectedRating,
      );
    } catch (e) {
      debugPrint("Error adding review: $e");
    }
  }

  Future<void> _toggleFavorite() async {
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    try {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('favorites')
          .doc(widget.place.id);

      if (isFavorite) {
        await ref.delete();
      } else {
        final favorite = FavoritePlace(
          userId: user!.uid,
          placeId: widget.place.id,
          title: widget.place.title,
          imageUrl: widget.place.imageUrl,
        );

        await ref.set(favorite.toFirestore());
      }
    } catch (e) {
      debugPrint("Favorite error: $e");
    }

    setState(() {
      isFavorite = !isFavorite;
      user = FirebaseAuth.instance.currentUser;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? "Added to favorites ❤️" : "Removed from favorites",
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      children: List.generate(5, (index) {
        final star = index + 1;
        return IconButton(
          icon: Icon(
            Icons.star,
            color: star <= _selectedRating ? Colors.amber : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _selectedRating = star.toDouble();
            });
          },
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final place = widget.place;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,

            child: Image.network(
              widget.place.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, object, stackTrace) {
                return const Icon(Icons.error);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),

          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleBtn(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),

                Row(
                  children: [
                    _buildFavoriteButton(theme),
                    const SizedBox(width: 8),
                    _circleBtn(
                      icon: Icons.map,
                      onTap: () {
                        // TODO
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.only(top: 260),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  place.city,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.star, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 6),
                    Text(
                      place.rating.toStringAsFixed(1),
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(place.category),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(place.description),

                const SizedBox(height: 24),

                Text("Reviews", style: theme.textTheme.titleMedium),

                const SizedBox(height: 12),

                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('placeId', isEqualTo: place.id)
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        // ignore: avoid_print
                        print(snapshot.error);
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final reviewDocs = snapshot.data?.docs ?? [];

                      final List<Review> firestoreReviews = reviewDocs
                          .map((review) => Review.fromFirestore(review))
                          .toList();

                      final allReviews = [...firestoreReviews];

                      if (allReviews.isEmpty) {
                        return const Center(
                          child: Text("No reviews yet. Be the first!"),
                        );
                      }

                      return ListView.separated(
                        itemCount: allReviews.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final r = allReviews[index];
                          return _buildReviewCard(r, theme);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildCommentInput(theme),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? Colors.white),
      ),
    );
  }

  Widget _buildReviewCard(Review r, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(r.userName[0]),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.userName, style: theme.textTheme.labelLarge),
                    Text(
                      "${r.date.toLocal()}".split(' ')[0],
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              Row(
                children: List.generate(
                  r.rating.toInt(),
                  (i) => Icon(
                    Icons.star,
                    size: 14,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(r.comment),
        ],
      ),
    );
  }

  Widget _buildCommentInput(ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRatingSelector(), // 👈 NOW USED

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Write a review...",
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
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _controller.text.trim().isEmpty
                        ? null
                        : _addReview,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(ThemeData theme) {
    if (user == null) {
      return _circleBtn(icon: Icons.favorite_border, onTap: _toggleFavorite);
    }

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(widget.place.id);

    return StreamBuilder<DocumentSnapshot>(
      stream: ref.snapshots(),
      builder: (context, snapshot) {
        final isFav = snapshot.data?.exists ?? false;

        return _circleBtn(
          icon: isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Theme.of(context).colorScheme.error : Colors.white,
          onTap: _toggleFavorite,
        );
      },
    );
  }
}
