import 'package:flutter/material.dart';
import 'package:locora/screens/admin/manage_splash_screen.dart';
import 'package:locora/widgets/admin/add_splash_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedIndex = 0;

  final screens = [
    const Center(child: Text("Dashboard Overview")),
    const ManagePlacesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: theme.primaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              child: const Text("Admin Panel"),
            ),
            ListTile(
              title: const Text("Dashboard"),
              onTap: () => setState(() => selectedIndex = 0),
            ),
            ListTile(
              title: const Text("Manage Places"),
              onTap: () => setState(() => selectedIndex = 1),
            ),
          ],
        ),
      ),
      body: screens[selectedIndex],
      floatingActionButton: selectedIndex == 1
          ? FloatingActionButton(
              backgroundColor: theme.primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPlaceScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
