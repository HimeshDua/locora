import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locora/types/index.dart';

Future<void> saveSelectedCityToFirebase(String cityName, String? uid) async {
  if (uid != null) {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'city': cityName,
    });
  }
}

Future<void> addReview({
  required String placeId,
  required String userName,
  required String comment,
  required double rating,
}) async {
  await FirebaseFirestore.instance.collection('reviews').add({
    'placeId': placeId,
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
