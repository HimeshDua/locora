import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locora/screens/auth/register.dart';
import 'package:locora/widgets/auth_textfield.dart';
import 'package:hugeicons/hugeicons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  bool isLoading = false;

  /// 🔥 VALIDATION
  bool validate() {
    setState(() {
      emailError = !RegExp(r'\S+@\S+\.\S+').hasMatch(emailController.text)
          ? "Enter a valid email"
          : null;

      passwordError = passwordController.text.isEmpty
          ? "Password is required"
          : null;
    });

    return emailError == null && passwordError == null;
  }

  /// 🔥 LOGIN LOGIC
  Future<void> login() async {
    if (!validate()) return;

    setState(() => isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful")));

      // 👉 TODO: Navigate to home screen
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      if (e.code == 'user-not-found') {
        message = "No account found with this email";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format";
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
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/greenery.jpeg', fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    colors.primary.withOpacity(0.2),
                    Colors.black.withOpacity(0.4),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          /// Optional soft blur (reduced)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: const SizedBox(),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surface.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors.outline.withOpacity(0.2)),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Branding
                      Text(
                        "Locora",
                        style: text.headlineLarge?.copyWith(
                          color: colors.primary,
                          fontSize: 34,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Discover your city like never before",
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Email
                      AuthTextField(
                        hint: "Email",
                        icon: HugeIcons.strokeRoundedMail01, // ✅ FIXED
                        controller: emailController,
                        errorText: emailError,
                      ),

                      const SizedBox(height: 16),

                      /// Password
                      AuthTextField(
                        hint: "Password",
                        icon: HugeIcons.strokeRoundedLock, // ✅ FIXED
                        obscure: true,
                        controller: passwordController,
                        errorText: passwordError,
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Forgot password?"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Login"),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: colors.outline)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text("OR", style: text.bodySmall),
                          ),
                          Expanded(child: Divider(color: colors.outline)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// Register Redirect
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "New here? ",
                              style: text.bodyMedium,
                              children: [
                                TextSpan(
                                  text: "Create account",
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
