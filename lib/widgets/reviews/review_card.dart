import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:locora/types/index.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final FThemeData theme;
  final String placeId;
  final bool isAdmin;

  const ReviewCard({
    super.key,
    required this.review,
    required this.theme,
    required this.placeId,
    this.isAdmin = false,
  });

  Future<void> _deleteReview(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .collection('reviews')
          .doc(review.id)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Review deleted')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete review')),
        );
      }
    }
  }

  Future<void> _toggleHidden(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .collection('reviews')
          .doc(review.id)
          .update({'hidden': !(review.hidden)});
    } catch (_) {}
  }

  Future<void> _toggleFeatured(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .collection('reviews')
          .doc(review.id)
          .update({'featured': !(review.featured)});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isHidden = review.hidden;
    final isFeatured = review.featured;

    return Opacity(
      opacity: isHidden ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colors.muted.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFeatured ? Colors.amber : theme.colors.border,
            width: 0.8,
          ),
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
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      if (isHidden)
                        Text(
                          'Hidden Review',
                          style: theme.typography.xs.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
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

                if (isAdmin) ...[
                  const SizedBox(width: 8),

                  PopupMenuButton<String>(
                    color: theme.colors.background,
                    onSelected: (value) async {
                      switch (value) {
                        case 'hide':
                          await _toggleHidden(context);
                          break;

                        case 'feature':
                          await _toggleFeatured(context);
                          break;

                        case 'delete':
                          await _deleteReview(context);
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'hide',
                        child: Text(isHidden ? 'Unhide Review' : 'Hide Review'),
                      ),

                      PopupMenuItem(
                        value: 'feature',
                        child: Text(
                          isFeatured ? 'Remove Featured' : 'Mark Featured',
                        ),
                      ),

                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Review'),
                      ),
                    ],
                    child: Icon(
                      FIcons.ellipsisVertical,
                      size: 18,
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
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
      ),
    );
  }
}
