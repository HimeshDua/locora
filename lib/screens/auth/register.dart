import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
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
      FToast(
        title: const Text('Please complete all fields'),
        variant: .destructive,
      );
      return;
    }

    if (password != confirmPassword) {
      FToast(
        title: const Text('Passwords do not match'),
        variant: .destructive,
      );
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
        'photoURL': '',
        'createdAt': FieldValue.serverTimestamp(),
        'admin': isAdmin(email) || false,
      });

      await user.updateDisplayName(name);

      final city = pakistaniCities.firstWhere((c) => c.name == selectedCity);
      await saveSelectedCity(city);

      // ignore: use_build_context_synchronously
      redirectBasedOnAuthnCity(context);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'email-already-in-use' => 'Email already in use',
        'invalid-email' => 'Invalid email',
        'weak-password' => 'Password is too weak',
        _ => 'Something went wrong',
      };
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final theme = FTheme.of(context);
    final heroHeight = (size.height * 0.32).clamp(200.0, 280.0);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(_bgImage, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.55, 1.0],
                      colors: [
                        Color.fromARGB(160, 0, 0, 0),
                        Color.fromARGB(100, 0, 0, 0),
                        Color.fromARGB(210, 0, 0, 0),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24, padding.top + 12, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icon/locora.png',
                            width: 22,
                            height: 22,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Locora',
                            style: theme.typography.md.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colors.foreground,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'Create account.',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Join Locora and start discovering Pakistan.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colors.border, width: 0.5),
                ),
              ),
              padding: EdgeInsets.fromLTRB(20, 18, 20, padding.bottom + 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FTextFormField(
                          label: Text(
                            'Full name',
                            style: TextStyle(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                          control: .managed(controller: nameController),
                          hint: 'Sara Khan',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          prefixBuilder: (context, style, variants) => Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Icon(
                              FIcons.user,
                              color: theme.colors.mutedForeground,
                              size: 16,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FSelect<String>.search(
                          label: Text(
                            'City',
                            style: TextStyle(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                          control: .managed(
                            controller: cityController,
                            onChange: (value) =>
                                setState(() => selectedCity = value),
                          ),
                          hint: 'Search…',
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
                                  (c) => c.toLowerCase().contains(
                                    query.toLowerCase(),
                                  ),
                                );
                          },
                          validator: (v) => v == null ? 'Select city' : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  FTextFormField.email(
                    label: Text(
                      'Email',
                      style: TextStyle(color: theme.colors.mutedForeground),
                    ),
                    control: .managed(controller: emailController),
                    hint: 'you@example.com',
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    prefixBuilder: (context, style, variants) => Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(
                        FIcons.mail,
                        color: theme.colors.mutedForeground,
                        size: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) 'Required';
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value!)) {
                        'Invalid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FTextFormField.password(
                          label: Text(
                            'Password',
                            style: TextStyle(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                          control: .managed(controller: passwordController),
                          hint: 'Min. 6 chars',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) 'Required';
                            if (value!.length < 6) return 'Min 6 chars';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FTextFormField.password(
                          label: Text(
                            'Confirm',
                            style: TextStyle(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                          control: .managed(
                            controller: confirmPasswordController,
                          ),
                          hint: 'Re-enter',
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) 'Required';
                            if (value != passwordController.text) 'No match';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  FButton(
                    variant: .primary,
                    onPress: isLoading ? null : _register,
                    child: isLoading
                        ? const FCircularProgress.loader()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Create account'),
                              const SizedBox(width: 8),
                              Icon(
                                FIcons.arrowRight,
                                color: theme.colors.primaryForeground,
                                size: 16,
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Expanded(child: FDivider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colors.mutedForeground,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      const Expanded(child: FDivider()),
                    ],
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => redirectToLogin(context),
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.colors.primary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
