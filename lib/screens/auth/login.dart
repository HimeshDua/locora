import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
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
      FToast(
        title: const Text('Please fill in all fields'),
        variant: .destructive,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (mounted) redirectBasedOnAuthnCity(context);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'user-not-found' => 'No account found with this email',
        'wrong-password' => 'Incorrect password',
        'invalid-email' => 'Invalid email format',
        _ => 'Login failed',
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

  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

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
    final padding = MediaQuery.paddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final theme = FTheme.of(context);
    final isKeyboardOpen = viewInsets.bottom > 0;
    final heroHeight = (size.height * (isKeyboardOpen ? 0.3 : 0.38)).clamp(
      isKeyboardOpen ? 180.0 : 220.0,
      isKeyboardOpen ? 240.0 : 320.0,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.colors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
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
                            padding: EdgeInsets.fromLTRB(
                              24,
                              padding.top + 12,
                              24,
                              24,
                            ),
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
                                  'Welcome back.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Sign in to continue exploring.',
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
                            top: BorderSide(
                              color: theme.colors.border,
                              width: 0.5,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          24,
                          20,
                          padding.bottom + 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FTextFormField.email(
                              label: Text(
                                'Email',
                                style: TextStyle(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                              control: .managed(controller: emailController),
                              hint: 'you@example.com',
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              prefixBuilder: (context, style, variants) =>
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Icon(
                                      FIcons.mail,
                                      color: theme.colors.mutedForeground,
                                      size: 16,
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

                            const SizedBox(height: 12),

                            FTextFormField.password(
                              label: Text(
                                'Password',
                                style: TextStyle(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                              control: .managed(controller: passwordController),
                              hint: 'Your password',
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: theme.colors.mutedForeground,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            FButton(
                              variant: .primary,
                              onPress: isLoading ? null : _login,
                              child: isLoading
                                  ? const FCircularProgress.loader()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Sign in',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          FIcons.arrowRight,
                                          color: theme.colors.primaryForeground,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                const Expanded(child: FDivider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
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

                            const SizedBox(height: 20),

                            FButton(
                              variant: .outline,
                              onPress: isLoading ? null : _signInWithGoogle,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FIcons.globe,
                                    color: theme.colors.foreground,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
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

                            const Spacer(),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    'Create one',
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
              ),
            ),
          );
        },
      ),
    );
  }
}
