import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Notifications",
          style: theme.typography.xl.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const _EmptyState();
          }

          final notifications = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _NotificationCard(data: notifications[index]);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final QueryDocumentSnapshot data;

  const _NotificationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    final title = data['title'] ?? '';
    final body = data['body'] ?? '';
    final timestamp = data['timestamp'];

    return FCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.colors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(FIcons.bell, size: 22, color: theme.colors.primary),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.lg.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  body,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      FIcons.calendar,
                      size: 14,
                      color: theme.colors.mutedForeground,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      _formatTime(timestamp),
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();

    return "${date.day}/${date.month}/${date.year}";
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: theme.colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(
                FIcons.bellOff,
                size: 38,
                color: theme.colors.primary,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              "No notifications yet",
              textAlign: TextAlign.center,
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            Text(
              "New places added by admin will appear here.",
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
