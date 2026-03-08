class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? duration;
  final String image;
  final double rating;
  final int numReviews;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.duration,
    required this.image,
    required this.rating,
    required this.numReviews,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'],
      image: json['image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      numReviews: json['numReviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'image': image,
      'rating': rating,
      'numReviews': numReviews,
    };
  }
}
