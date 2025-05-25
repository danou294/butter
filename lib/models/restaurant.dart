import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle représentant un restaurant, avec mapping des localisations
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
  final String? nameTagUrl;

  // Logo
  final String? logoUrl;
  final List<String>? imageUrls;

  /// Map label→code postal pour les arrondissements
  static const Map<String, String> arrondissementMap = {
    '1e':  '75001',  '2e':  '75002',  '3e':  '75003',  '4e':  '75004',
    '5e':  '75005',  '6e':  '75006',  '7e':  '75007',  '8e':  '75008',
    '9e':  '75009', '10e': '75010', '11e': '75011', '12e': '75012',
    '13e': '75013', '14e': '75014', '15e': '75015', '16e': '75016',
    '17e': '75017', '18e': '75018', '19e': '75019', '20e': '75020',
  };

  /// Map label→code postal pour les communes
  static const Map<String, String> communeMap = {
    'Boulogne':    '92100',
    'Levallois':   '92300',
    'Neuilly':     '92200',
    'Charenton':   '94220',
    'Saint-Mandé': '94160',
    'Saint-Ouen':  '93400',
    'Saint-Cloud': '92210',
  };

  /// Groupes de codes postaux par direction
  static const Map<String, List<String>> directionGroups = {
    'Ouest':  ['75015','75016','75017','75018','92200','92210','92300'],
    'Centre': ['75001','75002','75003','75004','75005','75006','75007','75008','75009'],
    'Est':    ['75010','75011','75012','75013','75014','75019','75020','93400','94160','94220'],
  };

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
    this.logoUrl,
    this.imageUrls,
  });

  /// Crée une instance depuis Firestore
  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Restaurant.fromMap(doc.id, data);
  }

  /// Crée une instance depuis un Map
  factory Restaurant.fromMap(String id, Map<String, dynamic> data) {
    // Helper pour normaliser en List<String>
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

    final address = data['address'] as Map<String, dynamic>? ?? {};
    final fullAddress = address['full'] as String? ?? '';
    final arr = address['arrondissement'];
    final arrondissement = arr is num ? arr.toInt() : 0;

    // On gère à la fois les champs 'cuisine' et 'cuisines'
    final rawCuisineField = data['cuisine'] ?? data['cuisines'];

    return Restaurant(
      id: id,
      name: data['name'] as String? ?? '',
      rawName: data['raw_name'] as String? ?? '',
      fullAddress: fullAddress,
      arrondissement: arrondissement,
      commentaire: data['commentaire'] as String? ?? '',
      hours: data['hours'] as String? ?? '',
      phone: (data['contact'] as Map<String, dynamic>?)?['phone'] as String? ?? '',
      website: (data['contact'] as Map<String, dynamic>?)?['website'] as String? ?? '',
      reservationLink: (data['contact'] as Map<String, dynamic>?)?['reservation_link'] as String? ?? '',
      instagram: (data['contact'] as Map<String, dynamic>?)?['instagram'] as String? ?? '',
      googleLink: (data['maps'] as Map<String, dynamic>?)?['google_link'] as String? ?? '',
      menuLink: (data['maps'] as Map<String, dynamic>?)?['menu_link'] as String? ?? '',
      restaurantType: extract(data['type']),
      ambiance: extract(data['ambiance']),
      cuisine: extract(rawCuisineField),
      priceRange: extract(data['price_range']),
      locationContext: extract(data['location_context']),
      services: extract(data['services']),
      restrictionsAlimentaires: extract(data['restrictions_alimentaires']),
      hasTerrace: (data['terrasse'] as Map<String, dynamic>?)?['has_terrasse'] as bool? ?? false,
      terraceTypes: extract((data['terrasse'] as Map<String, dynamic>?)?['type']),
      photoUrls: List<String>.from(data['photoUrls'] as List<dynamic>? ?? []),
      nameTagUrl: data['nameTagUrl'] as String?,
      logoUrl: data['logoUrl'] as String?,
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  /// Sérialise en Map pour Firestore ou cache
  Map<String, dynamic> toJson() {
    Map<String, dynamic> boolMap(List<String> keys) =>
        {for (var k in keys) k: true};

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
      'cuisines': boolMap(cuisine),
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
      'logoUrl': logoUrl,
      'imageUrls': imageUrls,
    };
  }
}
