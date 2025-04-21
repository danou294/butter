import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';

class RestaurantService {
  final _db = FirebaseFirestore.instance;

  Future<List<Restaurant>> fetchRestaurants() async {
    final snapshot = await _db.collection('restaurants').get();
    return snapshot.docs.map((doc) => Restaurant.fromMap(doc.data())).toList();
  }
}
