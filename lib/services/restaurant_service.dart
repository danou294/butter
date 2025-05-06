import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/restaurant.dart';

class RestaurantService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Restaurant>> fetchRestaurants() async {
    print('[RestaurantService] 🔄 Clearing cache before fetching...');
    await clearCache();

    try {
      final snapshot = await _db.collection('restaurants').get();

      final restaurants = snapshot.docs.map((doc) {
        final restaurant = Restaurant.fromFirestore(doc.data(), doc.id);

        if (restaurant.tagInitial.isNotEmpty) {
          final tag = restaurant.tagInitial.first;
          restaurant.photoUrls = _generateAllPhotoUrls(tag);
          restaurant.nameTagUrl = _generateNameTagUrl(tag);
        }

        return restaurant;
      }).toList();

      await cacheRestaurants(restaurants);
      return restaurants;
    } catch (e) {
      print('[RestaurantService] ❌ Error fetching restaurants: $e');
      return [];
    }
  }

  List<String> _generateAllPhotoUrls(String tagInitial) {
    final fileNames = [
      '${tagInitial}1.png',
      '${tagInitial}2.png',
      '${tagInitial}3.png',
      '${tagInitial}4.png',
      '${tagInitial}5.png',
    ];
    return fileNames.map((fileName) {
      final encoded = Uri.encodeComponent(fileName);
      return 'https://firebasestorage.googleapis.com/v0/b/butter-begin.firebasestorage.app/o/$encoded?alt=media';
    }).toList();
  }

  String _generateNameTagUrl(String tagInitial) {
    final fileName = '${tagInitial}1.png';
    final encoded = Uri.encodeComponent(fileName);
    return 'https://firebasestorage.googleapis.com/v0/b/butter-begin.firebasestorage.app/o/$encoded?alt=media';
  }

  Future<void> cacheRestaurants(List<Restaurant> restaurants) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded = restaurants.map((r) => jsonEncode({
      'id': r.id,
      'name': r.name,
      'trueName': r.trueName,
      'address': r.address,
      'phone': r.phone,
      'email': r.email,
      'website': r.website,
      'googleMaps': r.googleMaps,
      'reservation': r.reservation,
      'instagram': r.instagram,
      'plus': r.plus,
      'tagInitial': r.tagInitial,
      'restaurantType': r.restaurantType,
      'moment': r.moment,
      'locationType': r.locationType,
      'ambiance': r.ambiance,
      'priceRange': r.priceRange,
      'cuisine': r.cuisine,
      'diet': r.diet,
      'extras': r.extras,
      'photoUrls': r.photoUrls,
      'nameTagUrl': r.nameTagUrl,
    })).toList();

    await prefs.setStringList('restaurants_cache', encoded);
    print('[RestaurantService] 💾 Cached ${encoded.length} restaurants');
  }

  Future<List<Restaurant>> loadCachedRestaurants() async {
    print('[RestaurantService] 📦 Loading cached restaurants...');
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cachedData = prefs.getStringList('restaurants_cache');

    if (cachedData == null) {
      print('[RestaurantService] ❗ No cache found');
      return [];
    }

    final result = cachedData.map((jsonStr) {
      final data = jsonDecode(jsonStr);
      return Restaurant(
        id: data['id'],
        name: data['name'] ?? '',
        trueName: data['trueName'] ?? '',
        address: data['address'] ?? '',
        phone: data['phone'] ?? '',
        email: data['email'] ?? '',
        website: data['website'] ?? '',
        googleMaps: data['googleMaps'] ?? '',
        reservation: data['reservation'] ?? '',
        instagram: data['instagram'] ?? '',
        plus: data['plus'] ?? '',
        tagInitial: List<String>.from(data['tagInitial'] ?? []),
        restaurantType: List<String>.from(data['restaurantType'] ?? []),
        moment: List<String>.from(data['moment'] ?? []),
        locationType: List<String>.from(data['locationType'] ?? []),
        ambiance: List<String>.from(data['ambiance'] ?? []),
        priceRange: List<String>.from(data['priceRange'] ?? []),
        cuisine: List<String>.from(data['cuisine'] ?? []),
        diet: List<String>.from(data['diet'] ?? []),
        extras: List<String>.from(data['extras'] ?? []),
        photoUrls: List<String>.from(data['photoUrls'] ?? []),
        nameTagUrl: data['nameTagUrl'],
      );
    }).toList();

    print('[RestaurantService] ✅ Loaded ${result.length} restaurants from cache');
    return result;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('[RestaurantService] 🗑️ Cleared restaurant cache');
  }
}