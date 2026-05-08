// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locora/screens/auth/login.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/utils/is_indicators.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/utils/redirects.dart';
import 'package:locora/widgets/auth/auth_card.dart';
import 'package:locora/widgets/auth/auth_shell.dart';
import 'package:locora/widgets/auth_textfield.dart';
import 'package:hugeicons/hugeicons.dart';

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
  String? selectedCity;

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  bool isLoading = false;

  bool validate() {
    setState(() {
      nameError = nameController.text.isEmpty ? "Name is required" : null;

      emailError = !RegExp(r'\S+@\S+\.\S+').hasMatch(emailController.text)
          ? "Enter a valid email"
          : null;

      passwordError = passwordController.text.length < 6
          ? "Password must be at least 6 characters"
          : null;

      confirmPasswordError =
          passwordController.text != confirmPasswordController.text
          ? "Passwords do not match"
          : null;
    });

    if (selectedCity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a city")));
      return false;
    }

    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  Future<void> register() async {
    String name = nameController.text.trim();

    if (!validate()) return;

    setState(() => isLoading = true);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) throw Exception("User creation failed");

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "city": selectedCity,
        "email": emailController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
        "admin": isAdmin(emailController.text.trim()) || false,
      });

      await user.updateDisplayName(name);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Account created successfully")));
      redirectBasedOnAuthnCity(context);
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";

      if (e.code == 'email-already-in-use') {
        message = "Email already in use";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => isLoading = false);
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
                  /// ICON
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUserAdd01,
                        color: colors.primary,
                        size: 34,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// TITLE
                  Text(
                    "Create account",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Start discovering cities, attractions, restaurants, and unforgettable experiences with Locora.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 36),

                  /// FULL NAME
                  AuthTextField(
                    hint: "Full name",
                    icon: HugeIcons.strokeRoundedUser,
                    controller: nameController,
                    errorText: nameError,
                  ),

                  const SizedBox(height: 18),

                  /// CITY SELECTOR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF1B1B1B),
                        borderRadius: BorderRadius.circular(20),
                        isExpanded: true,
                        value: selectedCity,
                        hint: Text(
                          "Select your city",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowDown01,
                          color: Colors.white70,
                          size: 18,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        items: pakistaniCities.map((city) {
                          return DropdownMenuItem<String>(
                            value: city.name,
                            child: Text(city.name),
                          );
                        }).toList(),
                        onChanged: (String? city) {
                          setState(() {
                            selectedCity = city;

                            final selectedCityObject = pakistaniCities
                                .firstWhere(
                                  (c) => c.name == city,
                                  orElse: () => pakistaniCities.first,
                                );

                            saveSelectedCity(selectedCityObject);
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// EMAIL
                  AuthTextField(
                    hint: "Email address",
                    icon: HugeIcons.strokeRoundedMail01,
                    controller: emailController,
                    errorText: emailError,
                    inputType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 18),

                  /// PASSWORD
                  AuthTextField(
                    hint: "Password",
                    icon: HugeIcons.strokeRoundedLock,
                    obscure: true,
                    controller: passwordController,
                    errorText: passwordError,
                  ),

                  const SizedBox(height: 18),

                  /// CONFIRM PASSWORD
                  AuthTextField(
                    hint: "Confirm password",
                    icon: HugeIcons.strokeRoundedLockPassword,
                    obscure: true,
                    controller: confirmPasswordController,
                    errorText: confirmPasswordError,
                  ),

                  const SizedBox(height: 28),

                  /// CREATE ACCOUNT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,
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
                                  "Create account",
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

                  const SizedBox(height: 28),

                  /// DIVIDER
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          "ALREADY REGISTERED?",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Login instead",
                        style: TextStyle(fontWeight: FontWeight.w700),
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
}
