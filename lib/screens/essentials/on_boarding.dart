import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/screens/auth/login.dart';
import 'package:locora/utils/persistance.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();

  int currentPage = 0;

  final pages = [
    {
      "title": "Too many places,\nnot enough clarity",
      "description":
          "Locora helps travelers discover authentic places without wasting hours searching online.",
      "image": "assets/images/onboarding_1.png",
      "bg": const Color(0xFFF5F3EE),
    },
    {
      "title": "Discover hidden gems\nlike a local",
      "description":
          "Explore restaurants, attractions, and experiences recommended by locals and travelers.",
      "image": "assets/images/onboarding_2.png",
      "bg": const Color(0xFFFFF1F2),
    },
    {
      "title": "Your smart city\ntravel companion",
      "description":
          "Plan trips, explore cities, and save favorite places all inside one beautiful app.",
      "image": "assets/images/onboarding_3.png",
      "bg": const Color(0xFFECFDF5),
    },
  ];

  Future<void> finishOnboarding() async {
    await saveFirstTime(false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void nextPage() {
    if (currentPage < pages.length - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PageView.builder(
        controller: controller,
        itemCount: pages.length,
        onPageChanged: (value) {
          setState(() {
            currentPage = value;
          });
        },
        itemBuilder: (context, index) {
          final page = pages[index];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            color: page["bg"] as Color,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedMapsSquare01,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Locora",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        TextButton(
                          onPressed: finishOnboarding,
                          child: const Text("Skip"),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Hero(
                      tag: "onboarding-$index",
                      child: Image.asset(page["image"] as String, height: 320),
                    ),

                    const SizedBox(height: 40),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey(index),
                        children: [
                          Text(
                            page["title"] as String,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            page["description"] as String,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.black54,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(pages.length, (dotIndex) {
                        final active = dotIndex == currentPage;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 10,
                          width: active ? 30 : 10,
                          decoration: BoxDecoration(
                            color: active
                                ? theme.colorScheme.primary
                                : Colors.black12,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentPage == pages.length - 1
                                  ? "Get Started"
                                  : "Continue",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowRight01,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
