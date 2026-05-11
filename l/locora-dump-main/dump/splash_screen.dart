import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/wrapper/auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: Stack(
        children: [
          // Background gradients
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colors.primary.withOpacity(0.12),
              ),
            ),
          ),

          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colors.secondary.withOpacity(0.08),
              ),
            ),
          ),

          // Blur overlays
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  const Spacer(),

                  // Logo
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [theme.colors.primary, theme.colors.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 30,
                          spreadRadius: -8,
                          offset: const Offset(0, 18),
                          color: theme.colors.primary.withOpacity(0.35),
                        ),
                      ],
                    ),
                    child: const Icon(
                      HugeIcons.strokeRoundedMapsLocation02,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Brand
                  Text(
                    "LOCORA",
                    style: theme.typography.xl5.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Discover cities with elegance,\nclarity and confidence.",
                    textAlign: TextAlign.center,
                    style: theme.typography.base.copyWith(
                      color: theme.colors.mutedForeground,
                      height: 1.7,
                    ),
                  ),

                  const Spacer(),

                  // Bottom card
                  FCard(
                    padding: const EdgeInsets.all(18),
                    style: FCardStyle(
                      decoration: BoxDecoration(
                        color: theme.colors.background.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colors.border.withOpacity(0.4),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            HugeIcons.strokeRoundedNavigation03,
                            color: theme.colors.primary,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Exploring experiences",
                                style: theme.typography.sm.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Preparing your travel journey...",
                                style: theme.typography.xs.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: theme.colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
