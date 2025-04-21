import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/restaurant.dart';

class RestaurantService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      final snapshot = await _db.collection('restaurants').get();

      final restaurants = snapshot.docs.map((doc) {
        final restaurant = Restaurant.fromFirestore(doc.data(), doc.id);
        return restaurant;
      }).toList();

      for (final restaurant in restaurants) {
        restaurant.photoUrls = _generatePhotoUrls(restaurant.tag);
      }

      await cacheRestaurants(restaurants);
      return restaurants;
    } catch (e) {
      return [];
    }
  }

  List<String> _generatePhotoUrls(String tag) {
    return List.generate(4, (index) {
      final i = index + 2;
      final fileName = '$tag$i.png';
      final encodedPath = Uri.encodeComponent(fileName);
      return 'https://firebasestorage.googleapis.com/v0/b/butter-begin.firebasestorage.app/o/$encodedPath?alt=media';
    });
  }

  Future<void> cacheRestaurants(List<Restaurant> restaurants) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded = restaurants.map((r) => jsonEncode({
      'id': r.id,
      'vraiNom': r.vraiNom,
      'arrondissement': r.arrondissement,
      'typeCuisine': r.typeCuisine,
      'prix': r.prix,
      'tag': r.tag,
      'photoUrls': r.photoUrls,
    })).toList();
    await prefs.setStringList('restaurants_cache', encoded);
  }

  Future<List<Restaurant>> loadCachedRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cachedData = prefs.getStringList('restaurants_cache');

    if (cachedData == null) return [];

    return cachedData.map((jsonStr) {
      final data = jsonDecode(jsonStr);
      return Restaurant(
        id: data['id'],
        vraiNom: data['vraiNom'],
        arrondissement: data['arrondissement'],
        typeCuisine: data['typeCuisine'],
        prix: data['prix'],
        tag: data['tag'],
        photoUrls: List<String>.from(data['photoUrls'] ?? []),
      );
    }).toList();
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
