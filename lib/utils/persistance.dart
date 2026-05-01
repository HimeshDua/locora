import 'dart:convert';
import 'package:locora/types/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLoginState(bool isLoggedIn) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', isLoggedIn);
}

Future<bool> checkLoginState(bool isLoggedIn) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('is_logged_in') ?? false;
}

Future<void> saveSelectedCity(City city) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(city);
  await prefs.setString('selected_city', jsonString);
}

Future<City?> getSelectedCity() async {
  final prefs = await SharedPreferences.getInstance();
  final String? cityString = prefs.getString('selected_city');
  if (cityString == null) return null;

  Map<String, dynamic> cityMap = jsonDecode(cityString);
  return City.fromJson(cityMap);
}
