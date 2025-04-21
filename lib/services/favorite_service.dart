import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Récupère tous les IDs des restaurants en favoris
  Future<List<String>> getFavoriteRestaurantIds() async {
    if (_uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// Vérifie si un restaurant est dans les favoris
  Future<bool> isFavorite(String restaurantId) async {
    if (_uid == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(restaurantId)
        .get();

    return doc.exists;
  }

  /// Ajoute un restaurant aux favoris
  Future<void> addFavorite(String restaurantId) async {
    if (_uid == null) return;

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(restaurantId)
        .set({'addedAt': FieldValue.serverTimestamp()});
  }

  /// Retire un restaurant des favoris
  Future<void> removeFavorite(String restaurantId) async {
    if (_uid == null) return;

    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(restaurantId)
        .delete();
  }
}
