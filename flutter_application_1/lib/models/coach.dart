class Coach {
  final String id;
  final String name;
  final String specialty;
  final String experience;
  final List<String> certifications;
  final List<String> achievements;
  final String imageUrl;
  final String videoUrl;
  final double rating;
  final String price;
  final double? latitude;
  final double? longitude;
  final String? address;

  Coach({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.certifications,
    required this.achievements,
    required this.imageUrl,
    required this.videoUrl,
    required this.rating,
    required this.price,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory Coach.fromMap(Map<String, dynamic> data, String id) {
    return Coach(
      id: id,
      name: data['name'] ?? 'Unknown Coach',
      specialty: data['specialty'] ?? 'General Trainer',
      experience: data['experience'] ?? 'N/A',
      certifications: List<String>.from(data['certifications'] ?? []),
      achievements: List<String>.from(data['achievements'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      price: data['price'] ?? 'Contact for price',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      address: data['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'experience': experience,
      'certifications': certifications,
      'achievements': achievements,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'rating': rating,
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}
