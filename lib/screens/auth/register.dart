// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/utils/is_indicators.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/utils/redirects.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final cityController = FSelectController<String>();

  late final String _bgImage;
  String? selectedCity;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final n = Random().nextInt(5) + 1;
    _bgImage = 'assets/onboarding/$n.jpeg';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('User creation failed');

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'city': selectedCity,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'admin': isAdmin(email) || false,
      });

      await user.updateDisplayName(name);

      final city = pakistaniCities.firstWhere((c) => c.name == selectedCity);
      await saveSelectedCity(city);

      redirectBasedOnAuthnCity(context);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'email-already-in-use' => 'Email already in use',
        'invalid-email' => 'Invalid email',
        'weak-password' => 'Password is too weak',
        _ => 'Something went wrong',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final theme = FTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
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

          // Container(color: Colors.black.withValues(alpha: 0.64)),
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
                        Image.asset(
                          'assets/icon/locora.png',
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
                      'Create account.',
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
                      'Join Locora and start discovering Pakistan.',
                      style: TextStyle(
                        color: theme.colors.foreground.withAlpha(1200),
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: 32),

                    FTextFormField(
                      label: Text(
                        'Full name',
                        style: TextStyle(color: theme.colors.mutedForeground),
                      ),
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

                    const SizedBox(height: 16),

                    FSelect<String>.search(
                      label: Text(
                        'Your City',
                        style: TextStyle(color: theme.colors.mutedForeground),
                      ),
                      control: .managed(
                        controller: cityController,
                        onChange: (value) =>
                            setState(() => selectedCity = value),
                      ),
                      hint: 'Search city',
                      clearable: true,
                      contentScrollHandles: true,
                      items: {
                        for (final city in pakistaniCities)
                          city.name: city.name,
                      },
                      filter: (query) {
                        if (query.isEmpty) {
                          return pakistaniCities.map((e) => e.name);
                        }
                        return pakistaniCities
                            .map((e) => e.name)
                            .where(
                              (c) =>
                                  c.toLowerCase().contains(query.toLowerCase()),
                            );
                      },
                      validator: (v) =>
                          v == null ? 'Please select a city' : null,
                    ),

                    const SizedBox(height: 16),

                    FTextFormField.email(
                      label: Text(
                        'Email',
                        style: TextStyle(color: theme.colors.mutedForeground),
                      ),
                      control: .managed(controller: emailController),
                      hint: 'you@example.com',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      prefixBuilder: (context, value, child) => Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedMail01,
                          color: Colors.white.withValues(alpha: 0.45),
                          size: 17,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    FTextFormField.password(
                      label: Text(
                        'Password',
                        style: TextStyle(color: theme.colors.mutedForeground),
                      ),
                      control: .managed(controller: passwordController),
                      hint: 'Minimum 6 characters',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    FTextFormField.password(
                      label: Text(
                        'Confirm Password',
                        style: TextStyle(color: theme.colors.mutedForeground),
                      ),
                      control: .managed(controller: confirmPasswordController),
                      hint: 'Re-enter your password',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: FButton(
                        onPress: isLoading ? null : _register,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLoading)
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colors.muted,
                                ),
                              )
                            else ...[
                              Text(
                                'Create account',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: theme.colors.muted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowRight01,
                                color: theme.colors.muted,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(child: FDivider()),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'HAVE AN ACCOUNT?',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colors.mutedForeground,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(child: FDivider()),
                      ],
                    ),

                    const SizedBox(height: 28),

                    FButton(
                      variant: .outline,
                      onPress: () => redirectToLogin(context),
                      child: Text('Sign in instead'),
                    ),

                    SizedBox(height: bottom + 8),
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
