import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:locora/types/index.dart';
import 'package:locora/widgets/admin/add_or_edit_place.dart';

class ManagePlacesScreen extends StatefulWidget {
  const ManagePlacesScreen({super.key});

  @override
  State<ManagePlacesScreen> createState() => _ManagePlacesScreenState();
}

class _ManagePlacesScreenState extends State<ManagePlacesScreen> {
  String _query = '';
  final _searchController = TextEditingController();

  final _ref = FirebaseFirestore.instance.collection('places').orderBy('title');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(String id, String title) async {
    showFDialog(
      context: context,
      builder: (context, style, animation) => FDialog(
        style: style,
        animation: animation,
        direction: Axis.vertical,
        title: const Text('Delete place?'),
        body: Text(
          '"$title" will be permanently removed and cannot be recovered.',
        ),
        actions: [
          FButton(
            variant: .outline,
            onPress: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FButton(
            variant: .destructive,
            onPress: () async {
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
              await FirebaseFirestore.instance
                  .collection('places')
                  .doc(id)
                  .delete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(Place p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: FTheme.of(context).colors.background,
      builder: (_) => AddOrEditPlaceSheet(docId: p.id, existingData: p),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Scaffold(
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: FButton(
          onPress: () => {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: FTheme.of(context).colors.background,
              builder: (_) => AddOrEditPlaceSheet(),
            ),
          },
          child: Icon(FIcons.penLine),
        ),
      ),
      body: Column(
        children: [
          _buildSearch(theme),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _ref.snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colors.foreground,
                    ),
                  );
                }

                final places = (snap.data?.docs ?? [])
                    .map((e) => Place.fromFirestore(e))
                    .where(
                      (p) =>
                          p.title.toLowerCase().contains(_query.toLowerCase()),
                    )
                    .toList();

                if (places.isEmpty) return _buildEmpty(theme);

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: places.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _PlaceRow(
                    place: places[i],
                    theme: theme,
                    onEdit: () => _openEditSheet(places[i]),
                    onDelete: () =>
                        _confirmDelete(places[i].id, places[i].title),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(FThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: FTextField(
        hint: 'Search places…',
        control: .managed(
          controller: _searchController,
          onChange: (v) => setState(() => _query = v as String),
        ),
        prefixBuilder: (_, _, _) => Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Icon(
            FIcons.search,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
        ),
        suffixBuilder: _query.isNotEmpty
            ? (_, _, _) => GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                child: Icon(
                  FIcons.x,
                  size: 15,
                  color: theme.colors.mutedForeground,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildEmpty(FThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FIcons.searchX, size: 38, color: theme.colors.mutedForeground),
          const SizedBox(height: 12),
          Text(
            'No places found',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final Place place;
  final FThemeData theme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlaceRow({
    required this.place,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(place.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colors.border, width: 0.8),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: CachedNetworkImage(
                  imageUrl: place.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    width: 72,
                    height: 72,
                    color: theme.colors.muted,
                    child: Icon(
                      FIcons.imageOff,
                      size: 18,
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          FIcons.mapPin,
                          size: 12,
                          color: theme.colors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place.city,
                          style: theme.typography.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Chip(
                          label: place.rating.toStringAsFixed(1),
                          icon: FIcons.star,
                          color: const Color(0xFFF59E0B),
                          theme: theme,
                        ),
                        const SizedBox(width: 6),
                        _Chip(
                          label: place.category,
                          icon: FIcons.tag,
                          color: theme.colors.mutedForeground,
                          theme: theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _ActionButton(
                    icon: FIcons.pencil,
                    color: theme.colors.foreground,
                    bg: theme.colors.muted,
                    onTap: onEdit,
                  ),
                  const SizedBox(height: 6),
                  _ActionButton(
                    icon: FIcons.trash2,
                    color: const Color(0xFFEF4444),
                    bg: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final FThemeData theme;

  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.typography.xs.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
