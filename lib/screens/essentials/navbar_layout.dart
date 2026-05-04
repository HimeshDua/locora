import 'package:flutter/material.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/screens/admin/dashboard.dart';
import 'package:locora/screens/essentials/tabs/favorites_tab.dart';
import 'package:locora/screens/essentials/tabs/home_tab.dart';
import 'package:locora/screens/essentials/tabs/map_tab.dart';
import 'package:locora/screens/essentials/tabs/profile_tab.dart';
import 'package:locora/types/index.dart';

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

  late List pages = [
    HomeTab(city: widget.city),
    if (widget.admin == true) AdminDashboardScreen(),
    MapTab(city: widget.city ?? defaultCity),
    const FavoritesTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    int safeIndex = currentIndex >= pages.length ? 0 : currentIndex;

    return Scaffold(
      body: pages[safeIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: safeIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          if (widget.admin == true)
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
