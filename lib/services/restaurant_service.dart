// lib/services/restaurant_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/restaurant.dart';

/// Service for fetching restaurant data,
/// separating cache and network, normalizing fields,
/// and building logo URLs (with tokens).
class RestaurantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _cacheKey = 'restaurants_cache';
  static const _bucketName = 'butter-vdef.firebasestorage.app';
  static const _logosPath = 'Logos';
  static const _fileSuffix = '1';

  /// If you ever need to rotate tokens, stock them here by tag.
  static const Map<String, String> _tokenMap = {
    'ADL': '5563cf0e-1c0f-4a76-b6c7-a303dbc200c2',
    'ADR': 'a7dc8174-9efa-485f-b2a2-92a8c424e85d',
    // ... ajoutez tous vos tags ici ...
  };

  RestaurantService();

  /// Charge depuis le cache uniquement.
  Future<List<Restaurant>> fetchFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadFromCache(prefs);
  }

  /// Charge depuis Firestore, met à jour le cache, ou fallback sur le cache.
  Future<List<Restaurant>> fetchFromNetwork() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final snapshot = await _firestore.collection('restaurants').get();
      final list = snapshot.docs.map(_mapDocToRestaurant).toList();
      await _saveToCache(prefs, list);
      return list;
    } catch (e) {
      // Sur erreur réseau ou permission, on retombe sur le cache
      return _loadFromCache(prefs);
    }
  }

  /// Vide simplement les données mises en cache.
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  /// Transforme un DocumentSnapshot en Restaurant, en normalisant TOUTES vos valeurs Firestore.
  Restaurant _mapDocToRestaurant(DocumentSnapshot doc) {
    final raw = Map<String, dynamic>.from(doc.data() as Map);

    // 1) Normalisation des champs texte / bool / listes
    final normalized = <String, dynamic>{
      'name': raw['Vrai Nom'] ?? raw['rawName'] ?? '',
      'raw_name': raw['tag'] ?? '',
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
      // types et cuisine
      'type': raw['types'] is String
          ? [raw['types']]
          : (raw['types'] as List?) ?? [],
      'ambiance': {
        'classique': raw['ambiance_classique'] ?? false,
        'date': raw['ambiance_date'] ?? false,
        'festif': raw['ambiance_festif'] ?? false,
        'intimiste': raw['ambiance_intimiste'] ?? false,
      },
      'cuisine': raw['cuisines'] is String
          ? [raw['cuisines']]
          : (raw['cuisines'] as List?) ?? [],
      'price_range': raw['price_range'] is String
          ? [raw['price_range']]
          : (raw['price_range'] as List?) ?? [],
      'location_context': {
        'rue': raw['dans_la_rue'] ?? false,
        'hotel': raw['dans_un_hotel'] ?? false,
        'monument': raw['dans_un_monument'] ?? false,
        'musee': raw['dans_un_musee'] ?? false,
        'galerie': raw['dans_une_galerie'] ?? false,
      },
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
      'restrictions_alimentaires':
          raw['restrictions_alimentaires'] ?? <String, bool>{},
      'terrasse': {
        'has_terrasse': raw['has_terrace'] ?? raw['hasTerrace'] ?? false,
        'type': raw['terrace_locs'] is String
            ? [raw['terrace_locs']]
            : (raw['terrace_locs'] as List?) ?? [],
      },
      'photoUrls': raw['photoUrls'] is List
          ? List<String>.from(raw['photoUrls'])
          : <String>[],
    };

    // 2) Construction de l'URL du logo avec token
    final tag = (normalized['raw_name'] as String).trim().toUpperCase();
    if (tag.isNotEmpty && _tokenMap.containsKey(tag)) {
      final filename = '$tag$_fileSuffix.png';                  // ex: "ADL1.png"
      final path = Uri.encodeComponent('$_logosPath/$filename'); // "Logos%2FADL1.png"
      final token = _tokenMap[tag]!;
      normalized['nameTagUrl'] =
          'https://firebasestorage.googleapis.com/v0/b/$_bucketName/o/$path'
          '?alt=media&token=$token';
    } else {
      normalized['nameTagUrl'] = null;
    }

    // 3) Création finale du modèle
    return Restaurant.fromMap(doc.id, normalized);
  }

  /// Sauvegarde la liste en cache local
  Future<void> _saveToCache(
      SharedPreferences prefs, List<Restaurant> list) async {
    final jsonList = list.map((r) {
      final map = r.toJson()..['id'] = r.id;
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList(_cacheKey, jsonList);
  }

  /// Lecture depuis cache local
  List<Restaurant> _loadFromCache(SharedPreferences prefs) {
    final data = prefs.getStringList(_cacheKey);
    if (data == null || data.isEmpty) return [];
    return data.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      final id = map.remove('id') as String;
      return Restaurant.fromMap(id, map);
    }).toList();
  }
}
