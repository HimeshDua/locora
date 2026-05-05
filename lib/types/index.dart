import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  String id;
  String category; // 'Attraction', 'Restaurant', 'Hotel', 'Event'
  String title;
  String city;
  String description;
  double rating; // 1-5
  String googleMapsLink;
  String imageUrl;

  Place({
    required this.id,
    required this.category,
    required this.title,
    required this.city,
    required this.description,
    required this.rating,
    required this.googleMapsLink,
    required this.imageUrl,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Place(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      googleMapsLink: data['googleMapsLink'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      city: data['city'] ?? '',
    );
  }
}

class City {
  final String name;
  final String imageUrl;
  final String description;
  final String? funFact;

  City({
    required this.name,
    required this.imageUrl,
    required this.description,
    this.funFact,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': imageUrl,
    'description': description,
    'funFact': funFact,
  };

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'],
      description: json['description'],
      imageUrl: json['image'],
      funFact: json['funFact'],
    );
  }
}

class Review {
  final String id;
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;

  Review({
    required this.id,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Review(
      id: doc.id,
      userName: data['userName'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class FavoritePlace {
  final String userId;
  final String placeId;
  final String title;
  final String imageUrl;
  final DateTime? addedAt;

  FavoritePlace({
    required this.userId,
    required this.placeId,
    required this.title,
    required this.imageUrl,
    this.addedAt,
  });

  factory FavoritePlace.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FavoritePlace(
      userId: data['userId'] ?? '',
      placeId: data['placeId'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert Model -> Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'placeId': placeId,
      'title': title,
      'imageUrl': imageUrl,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}
