import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/screens/auth/login.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/utils/themes.dart';
import 'package:locora/widgets/auth/auth_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  final _pages = [
    _OnboardingPage(
      title: 'Find authentic places',
      description:
          'Discover attractions, restaurants and experiences curated just for you.',
      image: 'assets/images/onboarding_1.png',
      icon: HugeIcons.strokeRoundedMapsLocation01,
      accent: const Color(0xFFFF6B6B),
    ),
    _OnboardingPage(
      title: 'Discover hidden gems',
      description:
          'Explore real experiences recommended by locals who know the city best.',
      image: 'assets/images/onboarding_2.png',
      icon: HugeIcons.strokeRoundedCompass,
      accent: const Color(0xFF4ECDC4),
    ),
    _OnboardingPage(
      title: 'Your travel companion',
      description:
          'Everything you need to explore any city — all in one beautiful app.',
      image: 'assets/images/onboarding_3.png',
      icon: HugeIcons.strokeRoundedNavigation03,
      accent: const Color(0xFF9B59B6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await saveFirstTime(false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _onPageChanged(int index) {
    _fadeController.reset();
    setState(() => _currentPage = index);
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLast = _currentPage == _pages.length - 1;

    return AuthShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),

                _LogoRow(theme: theme),

                const SizedBox(height: AppSpacing.lg),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (_, i) =>
                        _PageCard(page: _pages[i], fadeAnim: _fadeAnim),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                _DotsIndicator(
                  count: _pages.length,
                  current: _currentPage,
                  colors: colors,
                ),

                const SizedBox(height: AppSpacing.lg),

                _NavRow(
                  isLast: isLast,
                  onSkip: _finish,
                  onNext: _next,
                  colors: colors,
                  theme: theme,
                ),

                SizedBox(
                  height: MediaQuery.of(context).padding.bottom + AppSpacing.md,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String description;
  final String image;
  final List<List<dynamic>> icon;
  final Color accent;
}

class _LogoRow extends StatelessWidget {
  const _LogoRow({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset('assets/icon/locora.png', width: 22, height: 22),
        ),
        const SizedBox(width: 10),
        Text(
          'Locora',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _PageCard extends StatelessWidget {
  const _PageCard({required this.page, required this.fadeAnim});

  final _OnboardingPage page;
  final Animation<double> fadeAnim;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return FadeTransition(
      opacity: fadeAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: colors.outlineVariant, width: 0.4),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.05),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            page.accent.withOpacity(0.08),
                            page.accent.withOpacity(0.03),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: page.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: HugeIcon(
                          icon: page.icon,
                          size: 20,
                          color: page.accent,
                        ),
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Image.asset(page.image, fit: BoxFit.contain),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: colors.outlineVariant),

              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        page.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        page.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.55,
                        ),
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
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.colors,
  });

  final int count;
  final int current;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: active ? 20 : 6,
          decoration: BoxDecoration(
            color: active
                ? colors.onSurface
                : colors.onSurface.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.isLast,
    required this.onSkip,
    required this.onNext,
    required this.colors,
    required this.theme,
  });

  final bool isLast;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final ColorScheme colors;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedOpacity(
          opacity: isLast ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: TextButton(
            onPressed: isLast ? null : onSkip,
            style: TextButton.styleFrom(
              foregroundColor: colors.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 10,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Skip',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 0,
              ),
            ),
          ),
        ),

        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          child: FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: colors.onSurface,
              foregroundColor: colors.surface,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                isLast ? 'Get started' : 'Continue',
                key: ValueKey(isLast),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.surface,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
