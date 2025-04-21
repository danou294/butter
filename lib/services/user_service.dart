import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;

  /// Vérifie si un utilisateur existe déjà
  Future<bool> userExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  /// Crée un utilisateur en Firestore
  Future<void> createUser({
    required String uid,
    required String phone,
    required String prenom,
    required String dateNaissance,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'phone': phone,
      'prenom': prenom.trim(),
      'dateNaissance': dateNaissance,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Récupère le prénom de l'utilisateur connecté
  Future<String?> fetchCurrentUserPrenom() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['prenom'];
  }

  /// Fonction de secours : récupérer l'objet complet de l'utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
