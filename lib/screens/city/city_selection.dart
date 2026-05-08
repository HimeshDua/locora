import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/firebase/actions.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/utils/redirects.dart';
import 'package:locora/widgets/auth/auth_card.dart';
import 'package:locora/widgets/auth/auth_shell.dart';
import 'package:locora/widgets/auth_textfield.dart';

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

  void onCitySearch(String value) {
    setState(() {
      filteredCities = CitySelectionScreen.cities
          .where(
            (city) => city.name.toLowerCase().contains(value.toLowerCase()),
          )
          .take(6)
          .toList();
    });
  }

  Future<void> saveUserName(String name, String uid) async {
    await FirebaseAuth.instance.currentUser?.updateDisplayName(name);

    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      "name": name,
    }, SetOptions(merge: true));
  }

  Future<void> submit() async {
    if (userId == null ||
        selectedCity == null ||
        nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await saveUserName(nameController.text.trim(), userId!);

      await saveSelectedCityToFirebase(selectedCity!.name, userId!);

      await saveSelectedCity(selectedCity!);

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil("/", (_) => false);
    } catch (_) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AuthShell(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AuthCard(
              // padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        color: colors.primary,
                        size: 34,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    "Personalize your journey",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Choose your city and tell us your name so Locora can personalize recommendations for you.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 36),

                  AuthTextField(
                    controller: nameController,
                    hint: "Your name",
                    icon: HugeIcons.strokeRoundedUser,
                  ),

                  const SizedBox(height: 18),

                  AuthTextField(
                    controller: cityController,
                    hint: "Search your city",
                    icon: HugeIcons.strokeRoundedMapsLocation01,
                    onChanged: onCitySearch,
                  ),

                  if (cityController.text.isNotEmpty) _suggestionsBox(theme),

                  if (selectedCity != null) ...[
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            color: colors.primary,
                            size: 22,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              selectedCity!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                const HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowRight01,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _suggestionsBox(ThemeData theme) {
    final colors = theme.colorScheme;

    if (filteredCities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Text(
          "No matching cities found",
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredCities.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
        itemBuilder: (_, index) {
          final city = filteredCities[index];

          final isSelected = selectedCity?.name == city.name;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                selectedCity = city;

                cityController.text = city.name;

                filteredCities = [];
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCity03,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      city.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  if (isSelected)
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      color: colors.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
