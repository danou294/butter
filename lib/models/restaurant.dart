import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  // Identifiants et libellés
  final String id;
  final String name;
  final String rawName;

  // Adresse
  final String fullAddress;
  final int arrondissement;

  // Commentaires et horaires
  final String commentaire;
  final String hours;

  // Contact
  final String phone;
  final String website;
  final String reservationLink;
  final String instagram;

  // Liens Maps et menu
  final String googleLink;
  final String menuLink;

  // Catégories multi-choix
  final List<String> restaurantType;
  final List<String> ambiance;
  final List<String> cuisine;
  final List<String> priceRange;
  final List<String> locationContext;
  final List<String> services;
  final List<String> restrictionsAlimentaires;

  // Terrasse
  final bool hasTerrace;
  final List<String> terraceTypes;

  // Médias
  final List<String> photoUrls;
  final String? nameTagUrl; // URL du logo stockée directement

  Restaurant({
    required this.id,
    required this.name,
    required this.rawName,
    required this.fullAddress,
    required this.arrondissement,
    required this.commentaire,
    required this.hours,
    required this.phone,
    required this.website,
    required this.reservationLink,
    required this.instagram,
    required this.googleLink,
    required this.menuLink,
    required this.restaurantType,
    required this.ambiance,
    required this.cuisine,
    required this.priceRange,
    required this.locationContext,
    required this.services,
    required this.restrictionsAlimentaires,
    required this.hasTerrace,
    required this.terraceTypes,
    this.photoUrls = const [],
    this.nameTagUrl,
  });

  /// Crée une instance à partir d'un DocumentSnapshot Firestore
  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Restaurant.fromMap(doc.id, data);
  }

  /// Crée une instance à partir d'un Map (cache ou Firestore)
  factory Restaurant.fromMap(String id, Map<String, dynamic> data) {
    List<String> extract(dynamic value) {
      if (value == null) return [];
      if (value is Map) {
        return value.entries
            .where((e) => e.value == true)
            .map((e) => e.key.toString())
            .toList();
      }
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String) {
        if (value.contains(',')) {
          return value.split(',').map((e) => e.trim()).toList();
        }
        return [value];
      }
      return [];
    }

    // Gestion adresse
    final address = data['address'] as Map<String, dynamic>? ?? {};
    final fullAddress = address['full'] as String? ?? '';
    final arrondissementNum = address['arrondissement'];
    final arrondissement = arrondissementNum is num
        ? arrondissementNum.toInt()
        : 0;

    return Restaurant(
      id: id,
      name: data['name'] as String? ?? '',
      rawName: data['raw_name'] as String? ?? '',
      fullAddress: fullAddress,
      arrondissement: arrondissement,
      commentaire: data['commentaire'] as String? ?? '',
      hours: data['hours'] as String? ?? '',
      phone: (data['contact'] as Map<String, dynamic>?)?['phone'] as String? ?? '',
      website:
          (data['contact'] as Map<String, dynamic>?)?['website'] as String? ?? '',
      reservationLink: (data['contact'] as Map<String, dynamic>?)?['reservation_link']
          as String? ?? '',
      instagram:
          (data['contact'] as Map<String, dynamic>?)?['instagram'] as String? ?? '',
      googleLink:
          (data['maps'] as Map<String, dynamic>?)?['google_link'] as String? ?? '',
      menuLink:
          (data['maps'] as Map<String, dynamic>?)?['menu_link'] as String? ?? '',
      restaurantType: extract(data['type']),
      ambiance: extract(data['ambiance']),
      cuisine: extract(data['cuisine']),
      priceRange: extract(data['price_range']),
      locationContext: extract(data['location_context']),
      services: extract(data['services']),
      restrictionsAlimentaires: extract(data['restrictions_alimentaires']),
      hasTerrace:
          (data['terrasse'] as Map<String, dynamic>?)?['has_terrasse'] as bool? ?? false,
      terraceTypes: extract(
          (data['terrasse'] as Map<String, dynamic>?)?['type']),
      photoUrls:
          List<String>.from(data['photoUrls'] as List<dynamic>? ?? []),
      nameTagUrl: data['nameTagUrl'] as String?,
    );
  }

  /// Sérialise en Map compatible Firestore et cache local
  Map<String, dynamic> toJson() {
    Map<String, dynamic> boolMap(List<String> list) =>
        Map.fromEntries(list.map((key) => MapEntry(key, true)));

    return {
      'name': name,
      'raw_name': rawName,
      'address': {
        'full': fullAddress,
        'arrondissement': arrondissement,
      },
      'commentaire': commentaire,
      'hours': hours,
      'contact': {
        'phone': phone,
        'website': website,
        'reservation_link': reservationLink,
        'instagram': instagram,
      },
      'maps': {
        'google_link': googleLink,
        'menu_link': menuLink,
      },
      'type': boolMap(restaurantType),
      'ambiance': boolMap(ambiance),
      'cuisine': boolMap(cuisine),
      'price_range': boolMap(priceRange),
      'location_context': boolMap(locationContext),
      'services': boolMap(services),
      'restrictions_alimentaires': boolMap(restrictionsAlimentaires),
      'terrasse': {
        'has_terrasse': hasTerrace,
        'type': boolMap(terraceTypes),
      },
      'photoUrls': photoUrls,
      'nameTagUrl': nameTagUrl,
    };
  }
}
