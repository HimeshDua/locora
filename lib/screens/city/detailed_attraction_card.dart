import 'package:flutter/material.dart';
import 'package:locora/types/index.dart';

class DetailAttractionScreen extends StatefulWidget {
  final Place place;

  const DetailAttractionScreen({super.key, required this.place});

  @override
  State<DetailAttractionScreen> createState() => _DetailAttractionScreenState();
}

class _DetailAttractionScreenState extends State<DetailAttractionScreen> {
  final TextEditingController _controller = TextEditingController();

  final double _selectedRating = 4;

  List<Review> reviews = [
    Review(
      userName: "Ali",
      comment: "Amazing place! Highly recommended.",
      rating: 4.5,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      userName: "Sara",
      comment: "Good experience but a bit crowded.",
      rating: 4,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  void _addReview() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      reviews.insert(
        0,
        Review(
          userName: "You",
          comment: _controller.text.trim(),
          rating: _selectedRating,
          date: DateTime.now(),
        ),
      );
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final place = widget.place;

    return Scaffold(
      body: Stack(
        children: [
          // IMAGE HEADER
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

          // BACK BUTTON
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
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

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.star, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 6),
                    Text(place.rating.toString()),
                  ],
                ),

                const SizedBox(height: 16),

                Text(place.description),

                const SizedBox(height: 24),

                Text("Reviews", style: theme.textTheme.titleMedium),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = reviews[index];
                      return _buildReviewCard(r, theme);
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
              CircleAvatar(radius: 14, child: Text(r.userName[0])),
              const SizedBox(width: 8),
              Text(r.userName, style: theme.textTheme.labelLarge),
              const Spacer(),
              Icon(Icons.star, size: 16, color: theme.colorScheme.tertiary),
              const SizedBox(width: 4),
              Text(r.rating.toString()),
            ],
          ),

          const SizedBox(height: 8),

          Text(r.comment, style: theme.textTheme.bodyMedium),
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
        child: Row(
          children: [
            // TEXT INPUT
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

            // SEND BUTTON
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _addReview,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
