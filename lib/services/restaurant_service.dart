// lib/services/restaurant_service.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/restaurant.dart';

/// Conteneur pour résultats paginés depuis Firestore.
class PaginatedRestaurants {
  final List<Restaurant> restaurants;
  final DocumentSnapshot? lastDocument;

  PaginatedRestaurants({
    required this.restaurants,
    this.lastDocument,
  });
}

/// Service pour gérer cache local et pagination Firestore des restaurants,
/// avec génération des URLs de logo et photos.
class RestaurantService {
  final FirebaseFirestore _firestore;

  static const String _cacheKey = 'restaurants_cache';
  static const String _bucketName = 'butter-vdef.firebasestorage.app';
  static const String _logosPath = 'Logos';
  static const String _photosPath = 'Photos restaurants';

  RestaurantService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Charge tous les restaurants depuis le cache local.
  Future<List<Restaurant>> fetchFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadFromCache(prefs);
  }

  /// Récupère une page de restaurants depuis Firestore, met à jour le cache complet.
  Future<PaginatedRestaurants> fetchPage({
    DocumentSnapshot? lastDocument,
    required int pageSize,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = _loadFromCache(prefs);
    try {
      var query = _firestore.collection('restaurants').limit(pageSize);
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      final snapshot = await query.get();
      final newList = snapshot.docs.map(_mapDocToRestaurant).toList();
      // Concatène et déduplique
      final map = <String, Restaurant>{};
      for (var r in [...existing, ...newList]) {
        map[r.id] = r;
      }
      final combined = map.values.toList();
      await _saveToCache(prefs, combined);
      return PaginatedRestaurants(
        restaurants: newList,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      );
    } catch (_) {
      // Fallback cache complet
      return PaginatedRestaurants(restaurants: existing, lastDocument: null);
    }
  }

  /// Vide le cache local.
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  /// Génère les URLs des photos (<TAG>2.png à <TAG>6.png).
  List<String> _generateImageUrls(String tag, {int min = 2, int max = 6}) =>
      List.generate(max - min + 1, (i) {
        final num = i + min;
        return _mediaUrl(_photosPath, '${tag}$num.png');
      });

  // Exemple de mapping pour les tokens d'images (à compléter selon tes besoins)
  final Map<String, String> _imageTokens = {
    'AKE2.png': '97db9b1d-ba1e-4ab4-a411-a3a4242cc7b7',
    // Ajoute ici les autres images et tokens si besoin
  };

  /// Génère une URL de média depuis Firebase Storage, avec gestion optionnelle du token.
  String _mediaUrl(String folder, String filename) {
    final path = Uri.encodeComponent('$folder/$filename');
    final token = _imageTokens[filename];
    return token != null
        ? 'https://firebasestorage.googleapis.com/v0/b/$_bucketName/o/$path?alt=media'
        : 'https://firebasestorage.googleapis.com/v0/b/$_bucketName/o/$path?alt=media';
  }

  /// Génère l'URL du logo (<TAG>1.png).
  String _generateLogoUrl(String tag) => _mediaUrl(_logosPath, '${tag}1.png');

  /// Transforme un DocumentSnapshot en Restaurant normalisé et ajoute URLs.
  Restaurant _mapDocToRestaurant(DocumentSnapshot doc) {
    final raw = Map<String, dynamic>.from(doc.data() as Map);
    final tag = (raw['tag'] ?? '').toString().toUpperCase();
    final logoUrl = tag.isNotEmpty ? _generateLogoUrl(tag) : null;
    final imageUrls = tag.isNotEmpty ? _generateImageUrls(tag) : <String>[];

    final data = <String, dynamic>{
      'name': raw['Vrai Nom'] ?? raw['rawName'] ?? '',
      'raw_name': tag,
      'address': {
        'full': raw['Adresse'] ?? '',
        'arrondissement': raw['Arrondissement'] ?? 0,
      },
      'hours': raw['Horaires'] ?? '',
      'commentaire': raw['more_info'] ?? '',
      'contact': {
        'phone': raw['Téléphone'] ?? '',
        'website': raw['Site web'] ?? '',
        'reservation_link': raw['Lien de réservation'] ?? '',
        'instagram': raw['Lien de votre compte instagram'] ?? '',
      },
      'maps': {
        'google_link': raw['Lien Google'] ?? '',
        'menu_link': raw['Lien Menu'] ?? '',
      },
      'type': raw['types'] is String ? [raw['types']] : (raw['types'] as List?) ?? <String>[],
      'ambiance': {
        'classique': raw['ambiance_classique'] ?? false,
        'date': raw['ambiance_date'] ?? false,
        'festif': raw['ambiance_festif'] ?? false,
        'intimiste': raw['ambiance_intimiste'] ?? false,
      },
      'cuisine': raw['cuisines'] is String ? [raw['cuisines']] : (raw['cuisines'] as List?) ?? <String>[],
      'price_range': raw['price_range'] is String ? [raw['price_range']] : (raw['price_range'] as List?) ?? <String>[],
      'services': {
        'dejeuner': raw['dejeuner'] ?? false,
        'diner': raw['diner'] ?? false,
        'drinks': raw['drinks'] ?? false,
        'apero': raw['apero'] ?? false,
        'brunch_dimanche': raw['brunch_dimanche'] ?? false,
        'brunch_samedi': raw['brunch_samedi'] ?? false,
        'brunch_general': raw['brunch_general'] ?? false,
        'brunch_toute_la_semaine': raw['brunch_toute_la_semaine'] ?? false,
        'gouter': raw['gouter'] ?? false,
        'petit_dejeuner': raw['petit_dejeuner'] ?? false,
      },
      'location_context': {
        'rue': raw['dans_la_rue'] ?? false,
        'hotel': raw['dans_un_hotel'] ?? false,
        'monument': raw['dans_un_monument'] ?? false,
        'musee': raw['dans_un_musee'] ?? false,
        'galerie': raw['dans_une_galerie'] ?? false,
      },
      'restrictions_alimentaires': raw['restrictions_alimentaires'] ?? <String, bool>{},
      'photoUrls': raw['photoUrls'] is List ? List<String>.from(raw['photoUrls']) : <String>[],
      'logoUrl': logoUrl,
      'imageUrls': imageUrls,
    };

    return Restaurant.fromMap(doc.id, data);
  }

  /// Sauvegarde la liste en cache local.
  Future<void> _saveToCache(SharedPreferences prefs, List<Restaurant> list) async {
    final jsonList = list.map((r) {
      final map = r.toJson()..['id'] = r.id;
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList(_cacheKey, jsonList);
  }

  /// Charge depuis cache local.
  List<Restaurant> _loadFromCache(SharedPreferences prefs) {
    final data = prefs.getStringList(_cacheKey);
    if (data == null || data.isEmpty) return <Restaurant>[];
    return data.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      final id = map.remove('id') as String;
      return Restaurant.fromMap(id, map);
    }).toList();
  }
}
