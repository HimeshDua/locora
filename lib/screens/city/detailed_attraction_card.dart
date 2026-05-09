import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/firebase/actions.dart';
import 'package:locora/widgets/reviews/review_section.dart';

class DetailAttractionScreen extends StatefulWidget {
  final Place place;
  const DetailAttractionScreen({super.key, required this.place});

  @override
  State<DetailAttractionScreen> createState() => _DetailAttractionScreenState();
}

class _DetailAttractionScreenState extends State<DetailAttractionScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  double _selectedRating = 4;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addReview() async {
    final text = _controller.text.trim();
    if (text.isEmpty || user?.displayName == null) return;
    _controller.clear();
    FocusScope.of(context).unfocus();
    await addReview(
      userId: user!.uid,
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
      await ref.set(
        FavoritePlace(
          userId: user!.uid,
          placeId: p.id,
          title: p.title,
          imageUrl: p.imageUrl,
          category: p.category,
          city: p.city,
          description: p.description,
          rating: p.rating,
          googleMapsLink: p.googleMapsLink,
        ).toFirestore(),
      );
    }
  }

  Future<void> _openMaps() async {
    final uri = Uri.parse(widget.place.googleMapsLink);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(theme),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildTitle(theme),
                    const SizedBox(height: 20),
                    _buildStats(theme),
                    const SizedBox(height: 20),
                    _buildActionRow(theme),
                    const SizedBox(height: 24),
                    _buildDivider(theme),
                    const SizedBox(height: 24),
                    _buildDescription(theme),
                    const SizedBox(height: 24),
                    _buildDivider(theme),
                    const SizedBox(height: 24),
                    buildReviewsSection(theme, widget.place.id),
                  ]),
                ),
              ),
            ],
          ),
          _buildBottomBar(theme),
        ],
      ),
    );
  }

  Widget _buildAppBar(FThemeData theme) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      leading: FButton.icon(
        variant: .outline,
        size: .sm,
        onPress: () => Navigator.pop(context),
        child: Icon(FIcons.arrowLeft, size: 18),
      ),
      actions: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .collection('favorites')
              .doc(widget.place.id)
              .snapshots(),
          builder: (_, snap) {
            final isFav = snap.data?.exists ?? false;
            return Row(
              children: [
                _NavButton(
                  icon: isFav ? FIcons.heartOff : FIcons.heart,
                  onTap: () => _toggleFavorite(isFav),
                  isActive: isFav,
                ),
                const SizedBox(width: 10),
                _NavButton(
                  icon: FIcons.mapPin,
                  onTap: _openMaps,
                  isActive: false,
                ),
                const SizedBox(width: 14),
              ],
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.place.imageUrl,
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.72),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FBadge(variant: .secondary, child: Text(widget.place.category)),
        const SizedBox(height: 10),
        Text(
          widget.place.title,
          style: theme.typography.xl3.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colors.foreground,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(FIcons.mapPin, size: 14, color: theme.colors.mutedForeground),
            const SizedBox(width: 5),
            Text(
              widget.place.city,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(FThemeData theme) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.star,
          label: widget.place.rating.toStringAsFixed(1),
          iconColor: Colors.amber,
          theme: theme,
        ),
        const SizedBox(width: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reviews')
              .where('placeId', isEqualTo: widget.place.id)
              .snapshots(),
          builder: (_, snap) {
            final count = snap.data?.docs.length ?? 0;
            return _StatChip(
              icon: FIcons.messageSquare,
              label: '$count reviews',
              theme: theme,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionRow(FThemeData theme) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('favorites')
          .doc(widget.place.id)
          .snapshots(),
      builder: (_, snap) {
        final isFav = snap.data?.exists ?? false;

        return Row(
          children: [
            Expanded(
              child: FButton(
                onPress: _openMaps,
                variant: .outline,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FIcons.mapPin, size: 15),
                    const SizedBox(width: 7),
                    const Text('Open in Maps'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FButton(
                onPress: () => _toggleFavorite(isFav),
                variant: isFav ? .primary : .outline,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFav ? FIcons.heartOff : FIcons.heart,
                      size: 15,
                      color: isFav ? Colors.white : null,
                    ),
                    const SizedBox(width: 7),
                    Text(isFav ? 'Saved' : 'Save'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDescription(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: theme.typography.lg.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.place.description,
          style: TextStyle(color: theme.colors.mutedForeground, height: 1.7),
        ),
      ],
    );
  }

  // Widget _buildReviewsSection(FThemeData theme) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Reviews',
  //         style: theme.typography.lg.copyWith(
  //           fontWeight: FontWeight.w700,
  //           color: theme.colors.foreground,
  //         ),
  //       ),
  //       const SizedBox(height: 14),
  //       StreamBuilder<QuerySnapshot>(
  //         stream: FirebaseFirestore.instance
  //             .collection('places')
  //             .doc(widget.place.id)
  //             .collection('reviews')
  //             .where('hidden', isEqualTo: false)
  //             .orderBy('date', descending: true)
  //             .snapshots(),
  //         builder: (_, snap) {
  //           if (snap.connectionState == ConnectionState.waiting) {
  //             return Center(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(24),
  //                 child: CircularProgressIndicator(
  //                   strokeWidth: 2,
  //                   color: theme.colors.foreground,
  //                 ),
  //               ),
  //             );
  //           }

  //           final reviews =
  //               snap.data?.docs.map((e) => Review.fromFirestore(e)).toList() ??
  //               [];

  //           if (reviews.isEmpty) {
  //             return Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 24),
  //               child: Center(
  //                 child: Column(
  //                   children: [
  //                     Icon(
  //                       FIcons.messageSquare,
  //                       size: 36,
  //                       color: theme.colors.mutedForeground,
  //                     ),
  //                     const SizedBox(height: 10),
  //                     Text(
  //                       'No reviews yet.\nBe the first to share your experience.',
  //                       textAlign: TextAlign.center,
  //                       style: theme.typography.sm.copyWith(
  //                         color: theme.colors.mutedForeground,
  //                         height: 1.6,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           }

  //           return Column(
  //             children: reviews
  //                 .map(
  //                   (r) => Padding(
  //                     padding: const EdgeInsets.only(bottom: 12),
  //                     child: _ReviewCard(review: r, theme: theme),
  //                   ),
  //                 )
  //                 .toList(),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDivider(FThemeData theme) =>
      Divider(height: 1, color: theme.colors.border);

  Widget _buildBottomBar(FThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            decoration: BoxDecoration(
              color: theme.colors.background.withValues(alpha: 0.88),
              border: Border(
                top: BorderSide(color: theme.colors.border, width: 0.8),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Your rating:',
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: List.generate(5, (i) {
                          final star = i + 1;
                          final filled = star <= _selectedRating;
                          return GestureDetector(
                            onTap: () => setState(
                              () => _selectedRating = star.toDouble(),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Icon(
                                Icons.star,
                                size: 20,
                                color: filled
                                    ? Colors.amber
                                    : theme.colors.mutedForeground.withValues(
                                        alpha: 0.4,
                                      ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: FTextField(
                          control: .managed(controller: _controller),
                          hint: 'Share your experience…',
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      FButton.icon(
                        onPress: _addReview,
                        child: Icon(FIcons.sendHorizontal, size: 17),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FTheme.of(context).colors;
    return FButton.icon(
      size: .sm,
      variant: .outline,
      onPress: onTap,
      child: Icon(
        icon,
        color: isActive ? colors.destructive : colors.foreground,
        size: 18,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final FThemeData theme;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.theme,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor ?? theme.colors.mutedForeground,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.typography.sm.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final FThemeData theme;

  const _ReviewCard({required this.review, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colors.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colors.foreground.withValues(alpha: 0.08),
                ),
                alignment: Alignment.center,
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colors.foreground,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.userName,
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colors.foreground,
                  ),
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  final filled = (i + 1) <= review.rating;
                  return Icon(
                    Icons.star,
                    size: 13,
                    color: filled
                        ? Colors.amber
                        : theme.colors.mutedForeground.withValues(alpha: 0.3),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
