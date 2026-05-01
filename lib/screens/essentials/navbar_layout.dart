import 'package:flutter/material.dart';
import 'package:locora/screens/essentials/tabs/favorites_tab.dart';
import 'package:locora/screens/essentials/tabs/home_tab.dart';
import 'package:locora/screens/essentials/tabs/map_tab.dart';
import 'package:locora/screens/essentials/tabs/profile_tab.dart';
import 'package:locora/types/index.dart';

class NavbarLayout extends StatefulWidget {
  final City city;
  const NavbarLayout({super.key, required this.city});

  @override
  State<NavbarLayout> createState() => _NavbarLayoutState();
}

class _NavbarLayoutState extends State<NavbarLayout> {
  int currentIndex = 0;

  late final List<Widget> pages = [
    HomeTab(city: widget.city),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
