import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/screens/admin/dashboard.dart';
import 'package:locora/screens/essentials/tabs/favorites_tab.dart';
import 'package:locora/screens/essentials/tabs/home_tab.dart';
import 'package:locora/screens/essentials/tabs/profile_tab.dart';
import 'package:locora/types/index.dart';
import 'package:locora/widgets/map/map_wrapper.dart';

class NavbarLayout extends StatefulWidget {
  final City? city;
  final bool? admin;

  const NavbarLayout({super.key, this.city, this.admin});

  @override
  State<NavbarLayout> createState() => _NavbarLayoutState();
}

class _NavbarLayoutState extends State<NavbarLayout> {
  int currentIndex = 0;
  final defaultCity = pakistaniCities[0];

  late final List<Widget> pages = [
    HomeTab(city: widget.city),
    if (widget.admin == true) const AdminDashboardScreen(),
    MapTabWrapper(city: widget.city ?? defaultCity),
    const FavoritesTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeIndex = currentIndex >= pages.length ? 0 : currentIndex;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey(safeIndex),
          child: SizedBox.expand(child: pages[safeIndex]),
        ),
      ),

      // 👇 MODERN FLOATING NAVBAR
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildItems(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems() {
    final items = [
      _NavItem(icon: HugeIcons.strokeRoundedHome01, label: "Home"),
      if (widget.admin == true)
        _NavItem(
          icon: HugeIcons.strokeRoundedDashboardSquare01,
          label: "Admin",
        ),
      _NavItem(icon: HugeIcons.strokeRoundedMaps, label: "Map"),
      _NavItem(icon: HugeIcons.strokeRoundedFavourite, label: "Favs"),
      _NavItem(icon: HugeIcons.strokeRoundedUser, label: "Profile"),
    ];

    return List.generate(items.length, (index) {
      final selected = currentIndex == index;

      return GestureDetector(
        onTap: () => setState(() => currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: items[index].icon,
                size: 22,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1,
                child: Text(
                  items[index].label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _NavItem {
  final dynamic icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
