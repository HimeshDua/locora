class Place {
  String category; // 'Attraction', 'Restaurant', 'Hotel', 'Event'
  String title;
  String city;
  String description;
  double rating; // 1-5
  String googleMapsLink;
  String imageUrl;

  Place({
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
