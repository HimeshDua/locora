import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locora/screens/auth/login.dart';
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

    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  Future<void> register() async {
    if (!validate()) return;
    print('dsads!');

    setState(() => isLoading = true);

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        print('User is currently signed out!');
      } else {
        print('User is signed in as ${user.email}');
      }
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user!.updateDisplayName(nameController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );
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

          /// Soft Blur
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
                      Text(
                        "Join Locora",
                        style: text.headlineLarge?.copyWith(
                          color: colors.primary,
                          fontSize: 32,
                        ),
                      ),

                      const SizedBox(height: 24),

                      AuthTextField(
                        hint: "Full Name",
                        icon: HugeIcons.strokeRoundedUser,
                        controller: nameController,
                        errorText: nameError,
                      ),

                      const SizedBox(height: 14),

                      AuthTextField(
                        hint: "Email",
                        icon: HugeIcons.strokeRoundedMail01,
                        controller: emailController,
                        errorText: emailError,
                      ),

                      const SizedBox(height: 14),

                      AuthTextField(
                        hint: "Password",
                        icon: HugeIcons.strokeRoundedLock,
                        obscure: true,
                        controller: passwordController,
                        errorText: passwordError,
                      ),

                      const SizedBox(height: 14),

                      AuthTextField(
                        hint: "Confirm Password",
                        icon: HugeIcons.strokeRoundedLock,
                        obscure: true,
                        controller: confirmPasswordController,
                        errorText: confirmPasswordError,
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => {register()},
                          style: ElevatedButton.styleFrom(
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
                              : const Text("Create Account"),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Already have an account? Login",
                            style: text.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SafeArea(
          //   child: Center(
          //     child: SingleChildScrollView(
          //       padding: const EdgeInsets.symmetric(horizontal: 20),
          //       child: Container(
          //         padding: const EdgeInsets.all(24),
          //         decoration: BoxDecoration(
          //           color: colors.surface.withOpacity(0.85),
          //           borderRadius: BorderRadius.circular(24),
          //           border: Border.all(color: colors.outline.withOpacity(0.2)),
          //         ),

          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               "Join Locora",
          //               style: text.headlineLarge?.copyWith(
          //                 color: colors.primary,
          //                 fontSize: 32,
          //               ),
          //             ),

          //             const SizedBox(height: 6),

          //             Text(
          //               "Create an account to explore your city",
          //               style: text.bodyMedium?.copyWith(
          //                 color: colors.onSurface.withOpacity(0.7),
          //               ),
          //             ),

          //             const SizedBox(height: 24),

          //             const AuthTextField(
          //               hint: "Full Name",
          //               icon: HugeIcons.strokeRoundedUser,
          //             ),

          //             const SizedBox(height: 14),

          //             const AuthTextField(
          //               hint: "Email",
          //               icon: HugeIcons.strokeRoundedMail01,
          //             ),

          //             const SizedBox(height: 14),

          //             const AuthTextField(
          //               hint: "Password",
          //               icon: HugeIcons.strokeRoundedLock,
          //               obscure: true,
          //             ),

          //             const SizedBox(height: 14),

          //             const AuthTextField(
          //               hint: "Confirm Password",
          //               icon: HugeIcons.strokeRoundedLock,
          //               obscure: true,
          //             ),

          //             const SizedBox(height: 20),

          //             SizedBox(
          //               width: double.infinity,
          //               child: ElevatedButton(
          //                 onPressed: () {},
          //                 style: ElevatedButton.styleFrom(
          //                   elevation: 0,
          //                   backgroundColor: colors.primary,
          //                   foregroundColor: Colors.white,
          //                   padding: const EdgeInsets.symmetric(vertical: 16),
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(16),
          //                   ),
          //                 ),
          //                 child: const Text(
          //                   "Create Account",
          //                   style: TextStyle(fontSize: 16),
          //                 ),
          //               ),
          //             ),

          //             const SizedBox(height: 16),

          //             Text(
          //               "By signing up, you agree to our Terms & Privacy Policy",
          //               style: text.bodySmall?.copyWith(
          //                 color: colors.onSurface.withOpacity(0.6),
          //               ),
          //             ),

          //             const SizedBox(height: 16),

          //             Row(
          //               children: [
          //                 Expanded(child: Divider(color: colors.outline)),
          //                 Padding(
          //                   padding: const EdgeInsets.symmetric(horizontal: 8),
          //                   child: Text("OR", style: text.bodySmall),
          //                 ),
          //                 Expanded(child: Divider(color: colors.outline)),
          //               ],
          //             ),

          //             const SizedBox(height: 16),

          //             Center(
          //               child: TextButton(
          //                 onPressed: () {
          //                   Navigator.pushReplacement(
          //                     context,
          //                     MaterialPageRoute(
          //                       builder: (_) => const LoginScreen(),
          //                     ),
          //                   );
          //                 },
          //                 child: Text.rich(
          //                   TextSpan(
          //                     text: "Already have an account? ",
          //                     style: text.bodyMedium,
          //                     children: [
          //                       TextSpan(
          //                         text: "Login",
          //                         style: TextStyle(
          //                           color: colors.primary,
          //                           fontWeight: FontWeight.w600,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
