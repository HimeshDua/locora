import 'package:flutter/material.dart';
import 'package:locora/screens/city/city_selection.dart';
import 'package:locora/screens/essentials/tabs/favorites.dart';
import 'package:locora/screens/essentials/tabs/home.dart';
import 'package:locora/screens/essentials/tabs/map.dart';
import 'package:locora/screens/essentials/tabs/profile.dart';

// 1. Define the StatefulWidget first
class MainScreen extends StatefulWidget {
  final City city; // Pass the city data here
  const MainScreen({super.key, required this.city});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// 2. Then define the State class
class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  // Use late to access 'widget.city' which is only available after initialization
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

// class MainScreen extends StatefulWidget {
//   final City city;

//   const MainScreen({super.key, required this.city});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int currentIndex = 0;

//   late final List<Widget> pages;

//   @override
//   void initState() {
//     super.initState();

//     pages = [
//       HomeTab(city: widget.city),
//       MapTab(city: widget.city),
//       FavoritesTab(),
//       ProfileTab(),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[currentIndex],

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: currentIndex,
//         onTap: (index) {
//           setState(() => currentIndex = index);
//         },
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Theme.of(context).colorScheme.primary,
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite),
//             label: "Favorites",
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }
