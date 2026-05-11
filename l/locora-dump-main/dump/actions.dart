 

Future<void> pushNotification({
  required String placeId,
  required String title,
  required String city,
  required bool isUpdated,
}) async {
  await FirebaseFirestore.instance.collection('notifications').add({
    'title': isUpdated ? 'Place Updated' : 'New Place Added',
    'body': isUpdated
        ? '$title has been updated in $city'
        : '$title added in $city',
    'placeId': placeId,
    'city': city,
    'type': isUpdated ? 'update' : 'create',
    'timestamp': FieldValue.serverTimestamp(),
  });
}

 