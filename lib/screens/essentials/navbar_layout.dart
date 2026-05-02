import 'package:flutter/material.dart';
import 'package:locora/screens/admin/dashboard.dart';
import 'package:locora/screens/essentials/tabs/favorites_tab.dart';
import 'package:locora/screens/essentials/tabs/home_tab.dart';
import 'package:locora/screens/essentials/tabs/map_tab.dart';
import 'package:locora/screens/essentials/tabs/profile_tab.dart';
import 'package:locora/types/index.dart';

class NavbarLayout extends StatefulWidget {
  final City city;
  final bool? admin;
  const NavbarLayout({super.key, required this.city, this.admin});

  @override
  State<NavbarLayout> createState() => _NavbarLayoutState();
}

class _NavbarLayoutState extends State<NavbarLayout> {
  int currentIndex = 0;
  late final bool isAdmin = widget.admin ?? false;

  late final List<Widget> pages = [
    HomeTab(city: widget.city),
    if (isAdmin) AdminDashboardScreen(),
    MapTab(city: widget.city),
    const FavoritesTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          if (isAdmin)
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
