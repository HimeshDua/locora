import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locora/screens/admin/dashboard.dart';
import 'package:locora/screens/auth/login.dart';
import 'package:locora/screens/city/city_selection.dart';
import 'package:locora/screens/essentials/navbar_layout.dart';
import 'package:locora/utils/is_indicators.dart';
import 'package:locora/utils/persistance.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            return const LoginScreen();
          }

          return FutureBuilder(
            future: getSelectedCity(),
            builder: (context, citySnapshot) {
              if (!citySnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final city = citySnapshot.data;

              if (city == null || city.name.isEmpty) {
                if (isAdmin(user.email!)) {
                  return const AdminDashboardScreen();
                } else {
                  return const CitySelectionScreen();
                }
              }

              return NavbarLayout(city: city);
            },
          );
        },
      ),
    );
  }
}
