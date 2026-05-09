import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/widgets/reviews/review_card.dart';

Widget buildReviewsSection(FThemeData theme, String placeId) {
  return FutureBuilder<bool>(
    future: getAdmin(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      bool isAdmin = snapshot.data ?? false;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: theme.typography.lg.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colors.foreground,
            ),
          ),
          const SizedBox(height: 14),
          StreamBuilder<QuerySnapshot>(
            stream: isAdmin
                ? FirebaseFirestore.instance
                      .collection('places')
                      .doc(placeId)
                      .collection('reviews')
                      .orderBy('date', descending: true)
                      .snapshots()
                : FirebaseFirestore.instance
                      .collection('places')
                      .doc(placeId)
                      .collection('reviews')
                      .where('hidden', isNotEqualTo: true)
                      .orderBy('date', descending: true)
                      .snapshots(),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colors.foreground,
                    ),
                  ),
                );
              }

              final reviews =
                  snap.data?.docs
                      .map((e) => Review.fromFirestore(e))
                      .toList() ??
                  [];

              if (reviews.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          FIcons.messageSquare,
                          size: 36,
                          color: theme.colors.mutedForeground,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No reviews yet.\nBe the first to share your experience.',
                          textAlign: TextAlign.center,
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: reviews
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ReviewCard(
                          review: r,
                          theme: theme,
                          placeId: placeId,
                          isAdmin: snapshot.data ?? false,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      );
    },
  );
}
