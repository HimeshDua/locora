import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/utils/redirects.dart';
import 'package:locora/utils/user_picture.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final user = FirebaseAuth.instance.currentUser;
  City? selectedCity;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCity();
  }

  Future<void> _fetchCity() async {
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final cityName = doc.data()?['city'];

    if (cityName != null) {
      selectedCity = pakistaniCities.firstWhere(
        (c) => c.name.toLowerCase() == cityName.toLowerCase(),
        orElse: () => pakistaniCities[0],
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _updateCity(City city) async {
    if (user == null) return;

    setState(() => selectedCity = city);

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'city': city.name,
    });

    await saveSelectedCity(city);
    if (context.mounted) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/').then((_) {
        setState(() {});
      });
    }
  }

  void _openCityPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: pakistaniCities.map((city) {
                final isSelected = selectedCity?.name == city.name;

                return ListTile(
                  leading: HugeIcon(
                    icon: isSelected
                        ? HugeIcons.strokeRoundedTick02
                        : HugeIcons.strokeRoundedLocation01,
                  ),
                  title: Text(city.name),
                  subtitle: Text(
                    city.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    _updateCity(city);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(theme),
            const SizedBox(height: 20),
            _buildQuickActions(theme),
            const SizedBox(height: 20),
            _buildCitySection(theme),
            const SizedBox(height: 30),
            _buildLogout(theme),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    Widget userPicture = getUserPicture(user?.displayName, user!.email!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: userPicture,
          ),
          const SizedBox(height: 12),
          Text(
            user?.displayName ?? "Traveler",
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? "",
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // 🔥 QUICK ACTIONS
  Widget _buildQuickActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionItem(
            "City",
            HugeIcons.strokeRoundedLocation01,
            _openCityPicker,
          ),
          _actionItem("Favorites", HugeIcons.strokeRoundedFavourite, () {}),
          _actionItem("Logout", HugeIcons.strokeRoundedLogout03, () {
            FirebaseAuth.instance.signOut();
            redirectAfterLogout(context);
          }),
        ],
      ),
    );
  }

  Widget _actionItem(
    String label,
    List<List<dynamic>> icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }

  // 🔥 CITY SECTION
  Widget _buildCitySection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your City", style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            if (selectedCity != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  "https://res.cloudinary.com/deedj7iii/image/upload/fl_preserve_transparency/v1777751572/ojd64j.jpg?_s=public-apps",
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                selectedCity!.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                selectedCity!.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ] else
              const Text("No city selected"),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _openCityPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Change City",
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogout(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          FirebaseAuth.instance.signOut();
          redirectAfterLogout(context);
        },
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedLogout05,
          color: theme.colorScheme.secondary,
        ),
        label: const Text("Logout"),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.secondary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
