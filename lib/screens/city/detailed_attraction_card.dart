import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
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
                  active: isFav,
                ),
                const SizedBox(width: 10),
                _glassBtn(HugeIcons.strokeRoundedMaps, () async {
                  // final uri = Uri.parse(place.googleMapsLink);

                  // if (await canLaunchUrl(uri)) {
                  //   await launchUrl(uri, mode: LaunchMode.externalApplication);
                  // }
                }),
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

            Container(
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(Place place, ThemeData theme) {
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          place.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedLocation01,
              size: 16,
              color: colors.primary,
            ),

            const SizedBox(width: 8),

            Text(
              place.city,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.72),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FBadge(child: Text(place.category)),

            FBadge(
              variant: .secondary,
              style: const .context(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedStar,
                    size: 14,
                    color: Colors.amber,
                  ),

                  const SizedBox(width: 6),

                  Text(place.rating.toStringAsFixed(1)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(Place place, ThemeData theme) {
    return FCard(
      mainAxisSize: .max,
      title: const Text('About this place'),
      subtitle: Text(place.description),
    );
  }

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

    return FCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text(
                r.userName[0].toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.userName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Row(
                      children: List.generate(
                        r.rating.toInt(),
                        (i) => const Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedStar,
                            size: 14,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  r.comment,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInput(ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;

                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedRating = star.toDouble();
                      });
                    },

                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedStar,
                      color: star <= _selectedRating
                          ? Colors.amber
                          : Colors.grey.shade500,
                      size: 22,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: FTextField(
                      control: .managed(controller: _controller),
                      hint: 'Share your experience...',
                    ),
                  ),

                  const SizedBox(width: 12),

                  FButton.icon(
                    onPress: _addReview,

                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedSent,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? Colors.red.withValues(alpha: 0.24)
                  : Colors.black.withValues(alpha: 0.28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: HugeIcon(icon: icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
