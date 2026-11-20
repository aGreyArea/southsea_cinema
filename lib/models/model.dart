class Movie {
  final String id;
  final String name;
  final String synopsis;
  final String ageRating;
  final String imagePath;
  final String screeningDate;
  final String screeningTime;
  final double price;

  const Movie({
    required this.id,
    required this.name,
    required this.synopsis,
    required this.ageRating,
    required this.imagePath,
    required this.screeningDate,
    required this.screeningTime,
    required this.price,
  });

  // Builds a Movie from one object in assets/data/movies.json.
  // JSON numbers can arrive as int (e.g. 7) or double (e.g. 7.5),
  // so price is read as num and converted to double.
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      name: json['name'] as String,
      synopsis: json['synopsis'] as String,
      ageRating: json['ageRating'] as String,
      imagePath: json['imagePath'] as String,
      screeningDate: json['screeningDate'] as String,
      screeningTime: json['screeningTime'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'synopsis': synopsis,
      'ageRating': ageRating,
      'imagePath': imagePath,
      'screeningDate': screeningDate,
      'screeningTime': screeningTime,
      'price': price,
    };
  }

  String get formattedPrice => '£${price.toStringAsFixed(2)}';

  String get screeningDateTime => '$screeningDate  $screeningTime';
}
