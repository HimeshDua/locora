import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/utils/redirects.dart';

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
    _fetchAndUpdateCity();
  }

  Future<void> _fetchAndUpdateCity() async {
    try {
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final cityName = userDoc['city'] as String?;
        if (cityName != null && cityName.isNotEmpty) {
          final city = pakistaniCities.firstWhere(
            (c) => c.name.toLowerCase() == cityName.toLowerCase(),
            orElse: () => pakistaniCities[0],
          );

          await saveSelectedCity(city);

          setState(() {
            selectedCity = city;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching city: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateCityInFirestore(City city) async {
    try {
      if (user == null) return;

      setState(() => selectedCity = city);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'city': city.name});

      await saveSelectedCity(city);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('City updated to ${city.name}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update city'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      debugPrint('Error updating city: $e');
    }
  }

  void _showCityPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select Your City',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pakistaniCities.length,
                itemBuilder: (context, index) {
                  final city = pakistaniCities[index];
                  final isSelected = selectedCity?.name == city.name;

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.location_city,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(city.name),
                    subtitle: Text(
                      // ignore: prefer_interpolation_to_compose_strings
                      city.description.substring(0, 50) + "...",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _updateCityInFirestore(city);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar Section
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Account Information',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.email ?? 'No Email',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // City Selection Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your City',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 16),
                          if (selectedCity != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    "https://res.cloudinary.com/deedj7iii/image/upload/fl_preserve_transparency/v1777751572/ojd64j.jpg?_s=public-apps",
                                    // selectedCity!.imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        child: Icon(
                                          Icons.location_city,
                                          size: 50,
                                          color: theme.colorScheme.primary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  selectedCity!.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  selectedCity!.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                          else
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No city selected',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showCityPicker,
                              icon: const Icon(Icons.location_on),
                              label: const Text('Change City'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        redirectAfterLogout(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
