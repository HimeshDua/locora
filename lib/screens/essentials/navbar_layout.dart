import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/main.dart';
import 'package:locora/screens/admin/dashboard.dart';
import 'package:locora/screens/essentials/tabs/favorites_tab.dart';
import 'package:locora/screens/essentials/tabs/home_tab.dart';
import 'package:locora/screens/essentials/tabs/profile_tab.dart';
import 'package:locora/screens/notification/notification_screen.dart';
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

  List<Widget> get pages => [
    HomeTab(city: widget.city),
    if (widget.admin == true) const AdminDashboardScreen(),
    MapTabWrapper(city: widget.city ?? defaultCity),
    const FavoritesTab(),
    NotificationScreen(),
    ProfileTab(
      isDarkMode: Application.of(context).isDarkMode,
      onThemeToggle: Application.of(context).toggleTheme,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final safeIndex = currentIndex >= pages.length ? 0 : currentIndex;

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(safeIndex),
          // child: MapTabWrapper(city: widget.city ?? defaultCity),
          child: pages[safeIndex],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildBottomBar(FThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(
          top: BorderSide(color: theme.colors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildItems(theme),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(FThemeData theme) {
    final List<_NavItem> items = [
      _NavItem(icon: FIcons.house, label: "Home"),
      if (widget.admin == true)
        _NavItem(icon: FIcons.layoutDashboard, label: "Admin"),
      _NavItem(icon: FIcons.map, label: "Map"),
      _NavItem(icon: FIcons.heart, label: "Favs"),
      _NavItem(icon: FIcons.bell, label: "Notification"),
      _NavItem(icon: FIcons.user, label: "Profile"),
    ];

    return List.generate(items.length, (index) {
      final isSelected = currentIndex == index;

      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => currentIndex = index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                items[index].icon,
                size: 20,
                color: isSelected
                    ? theme.colors.primary
                    : theme.colors.mutedForeground,
              ),

              // Only show label for selected item for a clean "Pill" look
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          items[index].label,
                          style: theme.typography.xs.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colors.primary,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
