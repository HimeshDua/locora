import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locora/types/index.dart';

Future<void> saveSelectedCityToFirebase(String cityName, String? uid) async {
  if (uid != null) {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'city': cityName,
    });
  }
}

Future<void> addReview({
  required String userId,
  required String placeId,
  required String userName,
  required String comment,
  required double rating,
}) async {
  await FirebaseFirestore.instance
      .collection('places')
      .doc(placeId)
      .collection('reviews')
      .add({
        'placeId': placeId,
        'userId': userId,
        'userName': userName,
        'comment': comment,
        'rating': rating,
        'date': FieldValue.serverTimestamp(),
      });
}

Future<List<Place>> fetchPlacesByCity(String cityName) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('places')
      .where('city', isEqualTo: cityName)
      .get();

  return snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
}

Future updateUserDisplayName(String name, String userId) async {
  await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
  await FirebaseFirestore.instance.collection('users').doc(userId).set({
    'name': name,
  }, SetOptions(merge: true));
}
