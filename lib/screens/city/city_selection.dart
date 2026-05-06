import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/firebase/actions.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/utils/redirects.dart';

class CitySelectionScreen extends StatefulWidget {
  const CitySelectionScreen({super.key});

  static final List<City> cities = pakistaniCities;

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  String? userId;

  final nameController = TextEditingController();
  final cityController = TextEditingController();

  List<City> filteredCities = [];

  City? selectedCity;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    redirectBasedOnStoredCity(context);
  }

  void _onCitySearch(String value) {
    setState(() {
      filteredCities = CitySelectionScreen.cities
          .where((c) => c.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> saveUserName(String name, String uid) async {
    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
    }, SetOptions(merge: true));
  }

  Future<void> _submit() async {
    if (userId == null ||
        selectedCity == null ||
        nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await saveUserName(nameController.text.trim(), userId!);
      await saveSelectedCityToFirebase(selectedCity!.name, userId!);
      await saveSelectedCity(selectedCity!);

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/greenery.jpeg", fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  /// TITLE
                  Text(
                    "Welcome to Locora 👋",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Let’s personalize your experience",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _inputField(
                    controller: nameController,
                    hint: "Your Name",
                    icon: HugeIcons.strokeRoundedUser,
                  ),

                  const SizedBox(height: 16),

                  _inputField(
                    controller: cityController,
                    hint: "Search your city...",
                    icon: HugeIcons.strokeRoundedLocation01,
                    onChanged: _onCitySearch,
                  ),

                  if (cityController.text.isNotEmpty) _suggestionsBox(theme),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.secondary,
                              ),
                            )
                          : Text(
                              "Continue",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required List<List<dynamic>> icon,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: theme.colorScheme.secondary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.hintColor),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: HugeIcon(icon: icon, color: theme.secondaryHeaderColor),
        ),
        filled: true,
        focusColor: theme.focusColor,
        fillColor: theme.highlightColor,
        hoverColor: theme.hoverColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// ================= SUGGESTIONS =================
  Widget _suggestionsBox(ThemeData theme) {
    if (filteredCities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          "No cities found",
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filteredCities.length,
        itemBuilder: (_, i) {
          final city = filteredCities[i];
          final isSelected = selectedCity?.name == city.name;

          return ListTile(
            onTap: () {
              setState(() {
                selectedCity = city;
                cityController.text = city.name;
                filteredCities = [];
              });
            },
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedCity03,
              color: isSelected ? theme.colorScheme.primary : Colors.white70,
            ),
            title: Text(city.name, style: const TextStyle(color: Colors.white)),
            trailing: isSelected
                ? HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkSquare02,
                    color: theme.colorScheme.primary,
                  )
                : null,
          );
        },
      ),
    );
  }
}
