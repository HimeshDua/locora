import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:locora/screens/auth/register.dart';
import 'package:locora/utils/redirects.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:locora/utils/is_indicators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late final String _bgImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final n = Random().nextInt(5) + 1;
    _bgImage = 'assets/onboarding/$n.jpeg';
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      redirectBasedOnAuthnCity(context);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'user-not-found' => 'No account found with this email',
        'wrong-password' => 'Incorrect password',
        'invalid-email' => 'Invalid email format',
        _ => 'Login failed',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      print("Juice");
      // GoogleSignIn.instance.initialize();
      print("Juice 1");
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      print("juice 2");
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      print("juice 3");

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      print("juice 4");

      final UserCredential userCred = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCred.user;

      if (user == null) throw Exception('Firebase User is null');

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final doc = await userDocRef.get();

      if (!doc.exists) {
        await userDocRef.set({
          'uid': user.uid,
          'name': user.displayName ?? 'Anonymous',
          'city': null,
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'admin': isAdmin(user.email!) || false,
        });
      }

      if (mounted) redirectBasedOnAuthnCity(context);
    } catch (e) {
      String errorMessage = 'An unexpected error occurred.';
      print(e);
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? 'Authentication failed.';
      } else if (e.toString().contains('network_error')) {
        errorMessage = 'Please check your internet connection.';
      }
      FToast(title: Text(errorMessage));
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
                        Image.asset(
                          'assets/icon/locora.png',
                          width: 26,
                          height: 26,
                        ),
                        const SizedBox(width: 8),
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
                      'Welcome back.',
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
                      'Sign in to continue exploring.',
                      style: TextStyle(
                        color: theme.colors.foreground.withAlpha(1200),
                        fontSize: 15,
                        height: 1.55,
                      ),
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
                      hint: 'Your password',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    SizedBox(
                      width: double.infinity,
                      child: FButton(
                        variant: .primary,
                        onPress: isLoading ? null : _login,

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
                                'Sign in',
                                style: TextStyle(
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

                    const SizedBox(height: 28),
                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(child: FDivider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colors.mutedForeground,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(child: const FDivider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: isLoading ? null : _signInWithGoogle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedGoogle,
                              color: theme.colors.foreground,
                              size: 17,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colors.foreground,
                                letterSpacing: -0.1,
                              ),
                            ),
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
                            'NEW HERE?',
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
                      onPress: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text('Create account'),
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
