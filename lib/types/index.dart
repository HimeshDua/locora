class PointOfInterest {
  String category; // 'Attraction', 'Restaurant', 'Hotel', 'Event'
  String title;
  String city;
  String description;
  double rating; // 1-5
  String googleMapsLink;
  String imageUrl;

  PointOfInterest({
    required this.category,
    required this.title,
    required this.city,
    required this.description,
    required this.rating,
    required this.googleMapsLink,
    required this.imageUrl,
  });
}

class City {
  final String name;
  final String image;
  final String description;

  City({required this.name, required this.image, required this.description});

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'description': description,
  };

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'],
      description: json['description'],
      image: json['image'],
    );
  }
}

class Review {
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;

  Review({
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
  });
}
