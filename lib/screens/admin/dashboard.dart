import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/screens/admin/manage_splash_screen.dart';
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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedDashboardSquare01,
              color: colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              "Admin Panel",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: colorScheme.onSurfaceVariant.withOpacity(0.6),
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Manage Places"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_OverviewTab(), ManagePlacesScreen()],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          return _tabController.index == 1
              ? FloatingActionButton.extended(
                  onPressed: () => _openAddSheet(context),
                  icon: const Icon(Icons.add),
                  label: const Text("New Place"),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddPlaceSheet(),
    );
  }
}

// --- OVERVIEW TAB (Responsive Grid) ---

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count
        int crossAxisCount = constraints.maxWidth > 900
            ? 4
            : (constraints.maxWidth > 600 ? 3 : 2);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Platform Stats",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _statCard(
                    context,
                    "Places",
                    "120",
                    HugeIcons.strokeRoundedLocation01,
                    Colors.blue,
                  ),
                  _statCard(
                    context,
                    "Cities",
                    "8",
                    HugeIcons.strokeRoundedBuilding06,
                    Colors.orange,
                  ),
                  _statCard(
                    context,
                    "Reviews",
                    "1.2k",
                    HugeIcons.strokeRoundedComment01,
                    Colors.green,
                  ),
                  _statCard(
                    context,
                    "Users",
                    "340",
                    HugeIcons.strokeRoundedUser,
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(
    BuildContext context,
    String title,
    String value,
    List<List<dynamic>> icon,
    Color accent,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: icon, color: accent, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
