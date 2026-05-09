import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:locora/screens/admin/manage_places.dart';
import 'package:locora/widgets/admin/add_place.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: FTheme.of(context).colors.background,
      builder: (_) => const AddPlaceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            _buildTabBar(theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [_OverviewTab(), ManagePlacesScreen()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _openAddSheet,
              backgroundColor: theme.colors.foreground,
              child: Icon(
                FIcons.plus,
                color: theme.colors.background,
                size: 20,
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(FThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Panel',
                style: theme.typography.xl2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colors.foreground,
                ),
              ),
              Text(
                'Manage your platform',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: theme.colors.muted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colors.border, width: 0.8),
            ),
            child: Icon(
              FIcons.layoutDashboard,
              size: 17,
              color: theme.colors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(FThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: theme.colors.muted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _Tab(
              label: 'Overview',
              selected: _tabController.index == 0,
              onTap: () => _tabController.animateTo(0),
              theme: theme,
            ),
            _Tab(
              label: 'Manage Places',
              selected: _tabController.index == 1,
              onTap: () => _tabController.animateTo(1),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final FThemeData theme;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? theme.colors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: theme.colors.border, width: 0.8)
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.typography.sm.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? theme.colors.foreground
                  : theme.colors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Platform stats at a glance',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 600 ? 4 : 2;
              final itemWidth = (constraints.maxWidth - (cols - 1) * 12) / cols;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    title: 'Places',
                    value: '120',
                    icon: FIcons.mapPin,
                    color: const Color(0xFF3B82F6),
                    width: itemWidth,
                    theme: theme,
                  ),
                  _StatCard(
                    title: 'Cities',
                    value: '8',
                    icon: FIcons.building2,
                    color: const Color(0xFFF97316),
                    width: itemWidth,
                    theme: theme,
                  ),
                  _StatCard(
                    title: 'Reviews',
                    value: '1.2k',
                    icon: FIcons.messageSquare,
                    color: const Color(0xFF22C55E),
                    width: itemWidth,
                    theme: theme,
                  ),
                  _StatCard(
                    title: 'Users',
                    value: '340',
                    icon: FIcons.users,
                    color: const Color(0xFFA855F7),
                    width: itemWidth,
                    theme: theme,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;
  final FThemeData theme;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colors.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.typography.xl2.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
