class Restaurant {
  final String id;
  final String name;
  final String trueName;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String googleMaps;
  final String reservation;
  final String instagram;
  final String plus;
  final List<String> tagInitial;
  final List<String> restaurantType;
  final List<String> moment;
  final List<String> locationType;
  final List<String> ambiance;
  final List<String> priceRange;
  final List<String> cuisine;
  final List<String> diet;
  final List<String> extras;
  List<String> photoUrls;
  String? nameTagUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.trueName,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.googleMaps,
    required this.reservation,
    required this.instagram,
    required this.plus,
    required this.tagInitial,
    required this.restaurantType,
    required this.moment,
    required this.locationType,
    required this.ambiance,
    required this.priceRange,
    required this.cuisine,
    required this.diet,
    required this.extras,
    this.photoUrls = const [],
    this.nameTagUrl,
  });

  factory Restaurant.fromFirestore(Map<String, dynamic> data, String docId) {
    final tags = Map<String, dynamic>.from(data['tags'] ?? {});
    return Restaurant(
      id: docId,
      name: data['name'] ?? '',
      trueName: data['true_name'] ?? '',
      address: data['address'] ?? '',
      phone: _parsePhone(data['phone']),
      email: data['email'] ?? '',
      website: data['website'] ?? '',
      googleMaps: data['google_maps'] ?? '',
      reservation: data['reservation'] ?? '',
      instagram: data['instagram'] ?? '',
      plus: data['plus'] ?? '',
      tagInitial: List<String>.from(tags['tag_initial'] ?? []),
      restaurantType: List<String>.from(tags['restaurant_type'] ?? []),
      moment: List<String>.from(tags['moment'] ?? []),
      locationType: List<String>.from(tags['location_type'] ?? []),
      ambiance: List<String>.from(tags['ambiance'] ?? []),
      priceRange: List<String>.from(tags['price_range'] ?? []),
      cuisine: List<String>.from(tags['cuisine'] ?? []),
      diet: List<String>.from(tags['diet'] ?? []),
      extras: List<String>.from(tags['extras'] ?? []),
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      nameTagUrl: data['nameTagUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'trueName': trueName,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'googleMaps': googleMaps,
      'reservation': reservation,
      'instagram': instagram,
      'plus': plus,
      'tags': {
        'tag_initial': tagInitial,
        'restaurant_type': restaurantType,
        'moment': moment,
        'location_type': locationType,
        'ambiance': ambiance,
        'price_range': priceRange,
        'cuisine': cuisine,
        'diet': diet,
        'extras': extras,
      },
      'photoUrls': photoUrls,
      'nameTagUrl': nameTagUrl,
    };
  }

  static String _parsePhone(dynamic phone) {
    if (phone is int || phone is double) {
      return phone.toInt().toString();
    }
    if (phone is String) {
      return phone;
    }
    return '';
  }
}