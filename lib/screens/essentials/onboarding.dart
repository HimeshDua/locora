import 'dart:math';

import 'package:flutter/material.dart';
import 'package:forui/widgets/button.dart';
import 'package:locora/screens/auth/login.dart';
import 'package:locora/utils/persistance.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final String _bgImage;

  @override
  void initState() {
    super.initState();
    final n = Random().nextInt(5) + 1;
    _bgImage = 'assets/onboarding/$n.jpeg';
  }

  Future<void> _continue() async {
    await saveFirstTime(false);
    if (!mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
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
                colors: [Colors.transparent, Colors.transparent, Colors.black],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Image.network(
                        'assets/icon/locora.png',
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Locora',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Text(
                    'Explore Pakistan,\nlike a local.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -1.0,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Discover authentic restaurants, hidden gems, and '
                    'curated experiences in your city — recommended by '
                    'people who actually live there.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 15,
                      height: 1.6,
                      letterSpacing: 0.1,
                    ),
                  ),

                  SizedBox(height: bottom + 36),

                  SizedBox(
                    width: double.infinity,
                    child: FButton(
                      variant: .primary,
                      onPress: _continue,
                      child: Text("Get Started"),
                    ),
                  ),

                  SizedBox(height: bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
