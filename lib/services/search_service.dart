// lib/services/search_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Map<String, List<String>> _zoneToArrondissements = {
    'Centre': ['1e', '2e', '3e', '4e', '5e', '6e'],
    'Ouest':  ['7e', '8e', '16e', '17e', '18e', '19e', '20e'],
    'Est':    ['9e', '10e', '11e', '12e', '13e', '14e', '15e'],
  };

  Future<List<Restaurant>> search({
    List<String>? directions,
    List<String>? arrondissements,
    List<String>? cuisines,
    List<String>? ambiances,
    List<String>? lieux,
    String? prixLevel,
    List<String>? restrictions,
  }) async {
    final Set<String> combinedArr = {};

    if (arrondissements != null) combinedArr.addAll(arrondissements);
    if (directions != null) {
      for (final dir in directions) {
        final zone = _zoneToArrondissements[dir];
        if (zone != null) combinedArr.addAll(zone);
      }
    }

    Query<Map<String, dynamic>> query = _firestore.collection('restaurants');

    if (combinedArr.isNotEmpty) {
      query = query.where(
        'arrondissement',
        whereIn: combinedArr.toList(),
      );
    }
    if (cuisines?.isNotEmpty == true) {
      query = query.where('cuisines', arrayContainsAny: cuisines!);
    }
    if (ambiances?.isNotEmpty == true) {
      query = query.where('ambiances', arrayContainsAny: ambiances!);
    }
    if (lieux?.isNotEmpty == true) {
      query = query.where('lieux', arrayContainsAny: lieux!);
    }
    if (restrictions?.isNotEmpty == true) {
      query = query.where('restrictions', arrayContainsAny: restrictions!);
    }
    if (prixLevel != null) {
      query = query.where('priceLevel', isEqualTo: prixLevel.length);
    }

    final snap = await query.get();
    return snap.docs
        .map((d) => Restaurant.fromMap(d.id, d.data()))
        .toList();
  }
}
