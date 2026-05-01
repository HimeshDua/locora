import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locora/screens/auth/register.dart';
import 'package:locora/screens/city/city_selection.dart';
import 'package:locora/screens/essentials/navbar_layout.dart';
import 'package:locora/utils/persistance.dart';

void redirectBasedOnStoredCity(BuildContext context) async {
  final storedCity = await getSelectedCity();
  if (!context.mounted) return;

  if (storedCity != null && storedCity.name.isNotEmpty) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => NavbarLayout(city: storedCity)),
    );
  }
}

void redirectBasedOnAuthnCity(BuildContext context) async {
  final storedCity = await getSelectedCity();
  final user = FirebaseAuth.instance.currentUser;

  if (!context.mounted) return;
  if (user != null && storedCity != null && storedCity.name.isNotEmpty) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => NavbarLayout(city: storedCity)),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CitySelectionScreen()),
    );
  }
}

void redirectAfterLogout(BuildContext context) async {
  final auth = FirebaseAuth.instance.currentUser;
  if (!context.mounted) return;
  if (auth == null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RegisterScreen()),
    );
  }
}
