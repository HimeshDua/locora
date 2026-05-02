import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locora/screens/admin/dashboard.dart';
import 'package:locora/screens/auth/login.dart';
import 'package:locora/screens/city/city_selection.dart';
import 'package:locora/screens/essentials/navbar_layout.dart';
import 'package:locora/types/index.dart';
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

          getUserData() async {
            final userData = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
            return userData;
          }

          return FutureBuilder(
            future: Future.wait([getUserData(), getSelectedCity()]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final DocumentSnapshot userDoc = snapshot.data![0];
              final City? city = snapshot.data![1];

              final userData = userDoc.data() as Map<String, dynamic>;

              late final bool admin = userData["admin"] ?? false;
              final String isCity = userData['city'] ?? '';

              if (city == null || city.name.isEmpty || isCity.isEmpty) {
                return CitySelectionScreen();
              }
              return NavbarLayout(city: city, admin: admin);
            },
          );
        },
      ),
    );
  }
}
