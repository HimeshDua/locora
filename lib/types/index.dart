import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  String id;
  String category;
  String title;
  String city;
  String description;
  double rating;
  String googleMapsLink;
  String imageUrl;

  double? lat;
  double? lng;

  Place({
    required this.id,
    required this.category,
    required this.title,
    required this.city,
    required this.description,
    required this.rating,
    required this.googleMapsLink,
    required this.imageUrl,
    this.lat,
    this.lng,
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
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
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
  final String placeId;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final bool hidden;
  final bool featured;
  final DateTime date;

  Review({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.hidden,
    required this.featured,
    required this.date,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Review(
      id: doc.id,
      userId: data['userId'] ?? '',
      placeId: data['placeId'] ?? '',
      userName: data['userName'] ?? '',
      comment: data['comment'] ?? '',
      hidden: data['hidden'] ?? false,
      featured: data['featured'] ?? false,
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

  final String category;
  final String city;
  final String description;
  final double rating;
  final String googleMapsLink;

  final DateTime? addedAt;

  FavoritePlace({
    required this.userId,
    required this.placeId,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.city,
    required this.description,
    required this.rating,
    required this.googleMapsLink,
    this.addedAt,
  });

  factory FavoritePlace.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FavoritePlace(
      userId: data['userId'] ?? '',
      placeId: data['placeId'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      city: data['city'] ?? '',
      description: data['description'] ?? '',
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] ?? 0.0).toDouble(),
      googleMapsLink: data['googleMapsLink'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'placeId': placeId,
      'title': title,
      'imageUrl': imageUrl,
      'category': category,
      'city': city,
      'description': description,
      'rating': rating,
      'googleMapsLink': googleMapsLink,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}
