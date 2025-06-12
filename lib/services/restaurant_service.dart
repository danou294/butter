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
      print('[DEBUG] Firestore snapshot docs count: [36m${snapshot.docs.length}[39m');
      if (snapshot.docs.isEmpty) print('[DEBUG] Aucun document retourné par la requête Firestore.');
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
    } catch (e, stack) {
      print('[DEBUG] Erreur lors de la requête Firestore: $e');
      print(stack);
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

  /// Génère l'URL du logo (<TAG>1.png).
  String _generateLogoUrl(String tag) => _mediaUrl(_logosPath, '${tag}1.png');

  /// Génère une URL de média depuis Firebase Storage.
  String _mediaUrl(String folder, String filename) {
    final path = Uri.encodeComponent('$folder/$filename');
    return 'https://firebasestorage.googleapis.com/v0/b/$_bucketName/o/$path?alt=media';
  }

  /// Transforme un DocumentSnapshot en Restaurant normalisé et ajoute URLs.
  Restaurant _mapDocToRestaurant(DocumentSnapshot doc) {
    final raw = Map<String, dynamic>.from(doc.data() as Map);
    final tag = (raw['tag'] ?? '').toString().toUpperCase();
    final logoUrl = tag.isNotEmpty ? _generateLogoUrl(tag) : null;
    final imageUrls = tag.isNotEmpty ? _generateImageUrls(tag) : <String>[];

    // DEBUG : Affiche le contenu brut et les champs critiques
    print('[DEBUG] Mapping doc ${doc.id}');
    print('[DEBUG] raw: ' + raw.toString());
    print('[DEBUG] Adresse: ' + (raw['Adresse']?.toString() ?? 'null'));
    print('[DEBUG] Arrondissement: ' + (raw['Arrondissement']?.toString() ?? 'null'));
    print('[DEBUG] Contact: ' + (raw['Téléphone']?.toString() ?? 'null') + ', ' + (raw['Site web']?.toString() ?? 'null'));
    print('[DEBUG] Cuisines: ' + (raw['cuisines']?.toString() ?? 'null'));
    print('[DEBUG] Types: ' + (raw['types']?.toString() ?? 'null'));
    print('[DEBUG] Ambiance: ' + (raw['ambiance']?.toString() ?? 'null'));
    print('[DEBUG] Lieux: ' + (raw['lieux']?.toString() ?? 'null'));
    print('[DEBUG] Moments: ' + (raw['moments']?.toString() ?? 'null'));
    print('[DEBUG] Restrictions: ' + (raw['restrictions']?.toString() ?? 'null'));
    print('[DEBUG] Terrace_locs: ' + (raw['terrace_locs']?.toString() ?? 'null'));
    print('[DEBUG] Station(s) de métro à proximité: ' + (raw['Station(s) de métro à proximité']?.toString() ?? 'null'));

    final data = <String, dynamic>{
      'name': raw['Vrai Nom'] ?? raw['rawName'] ?? '',
      'raw_name': tag,
      'address': {
        'full': raw['Adresse'] ?? '',
        'arrondissement': raw['Arrondissement'] ?? raw['arrondissement'] ?? 0,
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
      'types': raw['types'] is List ? raw['types'] : (raw['types'] is String && raw['types'].isNotEmpty) ? [raw['types']] : <String>[],
      'moments': raw['moments'] is List ? raw['moments'] : (raw['moments'] is String && raw['moments'].isNotEmpty) ? [raw['moments']] : <String>[],
      'lieux': raw['lieux'] is List ? raw['lieux'] : (raw['lieux'] is String && raw['lieux'].isNotEmpty) ? [raw['lieux']] : <String>[],
      'ambiance': raw['ambiance'] is List ? raw['ambiance'] : (raw['ambiance'] is String && raw['ambiance'].isNotEmpty) ? [raw['ambiance']] : <String>[],
      'price_range': raw['price_range'] ?? '',
      'cuisines': raw['cuisines'] is List ? raw['cuisines'] : (raw['cuisines'] is String && raw['cuisines'].isNotEmpty) ? [raw['cuisines']] : <String>[],
      'restrictions': raw['restrictions'] is List ? raw['restrictions'] : (raw['restrictions'] is String && raw['restrictions'].isNotEmpty) ? [raw['restrictions']] : <String>[],
      'has_terrace': raw['has_terrace'] ?? false,
      'terrace_locs': raw['terrace_locs'] is List ? raw['terrace_locs'] : (raw['terrace_locs'] is String && raw['terrace_locs'].isNotEmpty) ? [raw['terrace_locs']] : <String>[],
      'stations_metro': raw['Station(s) de métro à proximité'] is List ? raw['Station(s) de métro à proximité'] : (raw['Station(s) de métro à proximité'] is String && raw['Station(s) de métro à proximité'].isNotEmpty) ? [raw['Station(s) de métro à proximité']] : <String>[],
      'more_info': raw['more_info'] ?? '',
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
