import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveSelectedCityToFirebase(String cityName, String? uid) async {
  if (uid != null) {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'city': cityName,
    });
  }
}
