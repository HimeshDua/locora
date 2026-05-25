import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/firebase/actions.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/utils/redirects.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  static final List<City> cities = pakistaniCities;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final String _bgImage;

  String? userId;
  final nameController = TextEditingController();
  final cityController = FSelectController<String>();

  City? selectedCity;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final n = Random().nextInt(5) + 1;
    _bgImage = 'assets/onboarding/$n.jpeg';
    userId = FirebaseAuth.instance.currentUser?.uid;
    redirectBasedOnStoredCity(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = nameController.text.trim();

    if (userId == null || selectedCity == null || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await updateUserDisplayName(name, userId!);
      await saveSelectedCityToFirebase(selectedCity!.name, userId!);
      await saveSelectedCity(selectedCity!);

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } catch (_) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _bgImage,
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
          ),

          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.45, 1.0],
                colors: [
                  Color.fromARGB(64, 0, 0, 0),
                  Color.fromARGB(153, 0, 0, 0),
                  Color.fromARGB(155, 0, 0, 0),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(28, 16, 28, bottom + 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        CachedNetworkImage(
                          imageUrl: 'assets/icon/locora.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'Locora',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    const Text(
                      'Almost there.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Tell us who you are and where you are — '
                      'we\'ll handle the rest.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: 40),

                    _Label('Full name'),
                    const SizedBox(height: 8),
                    FTextFormField(
                      control: .managed(controller: nameController),
                      hint: 'e.g. Sara Khan',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      prefixBuilder: (context, value, child) => Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedUser,
                          color: Colors.white.withValues(alpha: 0.45),
                          size: 17,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),

                    const SizedBox(height: 24),

                    _Label('Your city'),
                    const SizedBox(height: 8),
                    FSelect<String>.search(
                      control: .managed(
                        controller: cityController,
                        onChange: (value) {
                          setState(() {
                            selectedCity = value == null
                                ? null
                                : SetupScreen.cities.firstWhere(
                                    (c) => c.name == value,
                                  );
                          });
                        },
                      ),
                      hint: 'Search city',
                      clearable: true,
                      contentScrollHandles: true,
                      items: {
                        for (final city in SetupScreen.cities)
                          city.name: city.name,
                      },
                      filter: (query) {
                        if (query.isEmpty) {
                          return SetupScreen.cities.map((e) => e.name);
                        }
                        return SetupScreen.cities
                            .map((e) => e.name)
                            .where(
                              (c) =>
                                  c.toLowerCase().contains(query.toLowerCase()),
                            );
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: FButton(
                        onPress: isLoading ? null : _submit,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLoading)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else ...[
                              const Text(
                                'Start exploring',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowRight01,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.50),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    ),
  );
}
