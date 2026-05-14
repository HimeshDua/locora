import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:locora/screens/auth/login.dart';
import 'package:locora/screens/essentials/setup_screen.dart';
import 'package:locora/screens/essentials/navbar_layout.dart';
import 'package:locora/screens/essentials/onboarding.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/persistance.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<DocumentSnapshot?> _getUserDoc(String uid) async {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authSnapshot.data;

          return FutureBuilder<bool>(
            future: getFirstTime(),
            builder: (context, firstTimeSnapshot) {
              if (!firstTimeSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final isFirstTime = firstTimeSnapshot.data!;

              if (isFirstTime) {
                return const OnboardingScreen();
              }

              if (user == null) {
                return const LoginScreen();
              }

              return FutureBuilder<DocumentSnapshot?>(
                future: _getUserDoc(user.uid),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userDoc = userSnapshot.data;

                  if (userDoc == null || !userDoc.exists) {
                    return const SetupScreen();
                  }

                  final data = userDoc.data() as Map<String, dynamic>;

                  final String city = data["city"] ?? "";
                  final bool admin = data["admin"] ?? false;

                  if (admin) {
                    saveAdmin(admin);
                  }

                  if (city.isEmpty) {
                    return const SetupScreen();
                  }

                  return FutureBuilder<City?>(
                    future: getSelectedCity(),
                    builder: (context, citySnapshot) {
                      if (!citySnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return NavbarLayout(
                        city: citySnapshot.data!,
                        admin: admin,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
