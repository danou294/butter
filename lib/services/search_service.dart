// lib/services/search_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';

/// Service de recherche de restaurants basé sur localisation, moments, lieux, cuisines et prix,
/// avec génération automatique des URLs de logo et photos.
class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Storage bucket et chemins
  static const String _bucketName = 'butter-vdef.firebasestorage.app';
  static const String _logosPath = 'Logos';
  static const String _photosPath = 'Photos restaurants';

  /// Recherche les restaurants selon les filtres :
  /// - [zones], [arrondissements], [communes] pour la géolocalisation.
  /// - [moments], [lieux], [cuisines], [prix] pour les critères.
  Future<List<Restaurant>> search({
    List<String>? zones,
    List<String>? arrondissements,
    List<String>? communes,
    List<String>? moments,
    List<String>? lieux,
    List<String>? cuisines,
    List<String>? prix,
  }) async {
    // 1) Construction des groupes de codes postaux (OR géo)
    final geoGroups = _buildGeoGroups(zones, arrondissements, communes);

    // 2) Exécution des requêtes Firestore et enrichissement média
    final Map<String, Restaurant> resultsMap = {};
    for (var codes in geoGroups) {
      // Appliquer tous les filtres
      var query = _applyFilters(
        _firestore.collection('restaurants') as Query<Map<String, dynamic>>,
        codes: codes,
        moments: moments,
        lieux: lieux,
        cuisines: cuisines,
        prix: prix,
      );

      // Exécution
      final snap = await query.get();
      for (var doc in snap.docs) {
        // on passe par fromMap pour récupérer logos + images
        resultsMap[doc.id] = _mapDocToRestaurant(doc);
      }
    }

    // 3) Retourner la liste sans doublons
    return resultsMap.values.toList();
  }

  List<List<int>> _buildGeoGroups(
    List<String>? zones,
    List<String>? arrondissements,
    List<String>? communes,
  ) {
    final arrMap = Restaurant.arrondissementMap;
    final commMap = Restaurant.communeMap;

    const zoneArrLabels = {
      'Centre': ['1e','2e','3e','4e','5e','6e','7e','8e','9e'],
      'Ouest':  ['15e','16e','17e','18e'],
      'Est':    ['10e','11e','12e','13e','14e','19e','20e'],
    };
    const zoneCommunes = {
      'Ouest': ['Boulogne','Levallois','Neuilly','Saint-Cloud'],
      'Centre': [],
      'Est':    ['Charenton','Saint-Mandé','Saint-Ouen'],
    };
    const zoneExtra = {
      'Centre': ['75116'],
      'Ouest':  ['92270','92800'],
      'Est':    ['93110'],
    };

    final groups = <List<int>>[];

    void add(Set<String> codes) {
      final ints = codes.map(int.tryParse).whereType<int>().toList();
      if (ints.isNotEmpty) groups.add(ints);
    }

    // a) zones
    if (zones != null && zones.isNotEmpty) {
      for (var z in zones) {
        final codes = <String>{};
        for (var lbl in zoneArrLabels[z] ?? []) {
          final c = arrMap[lbl];
          if (c != null) codes.add(c);
        }
        for (var lbl in zoneCommunes[z] ?? []) {
          final c = commMap[lbl];
          if (c != null) codes.add(c);
        }
        codes.addAll(zoneExtra[z] ?? []);
        add(codes);
      }
    }

    // b) arrondissements
    if (arrondissements != null && arrondissements.isNotEmpty) {
      final codes = <String>{};
      for (var lbl in arrondissements) {
        final c = arrMap[lbl];
        if (c != null) codes.add(c);
        if (lbl == '16e') codes.add('75116');
      }
      add(codes);
    }

    // c) communes
    if (communes != null && communes.isNotEmpty) {
      final codes = communes
          .map((lbl) => commMap[lbl])
          .whereType<String>()
          .toSet();
      add(codes);
    }

    // si rien, un groupe vide pour ne pas bloquer filtres non-géo
    if (groups.isEmpty) groups.add([]);

    return groups;
  }

  Query<Map<String, dynamic>> _applyFilters(
    Query<Map<String, dynamic>> query, {
    required List<int> codes,
    List<String>? moments,
    List<String>? lieux,
    List<String>? cuisines,
    List<String>? prix,
  }) {
    // localisation
    if (codes.isNotEmpty) {
      query = codes.length == 1
          ? query.where('address.arrondissement', isEqualTo: codes.first)
          : query.where('address.arrondissement', whereIn: codes);
    }
    // moments
    for (var m in moments ?? []) {
      query = query.where(m, isEqualTo: true);
    }
    // lieux
    for (var l in lieux ?? []) {
      query = query.where('location_context.$l', isEqualTo: true);
    }
    // cuisines
    if ((cuisines ?? []).isNotEmpty) {
      query = query.where('cuisines', arrayContainsAny: cuisines!);
    }
    // prix
    if ((prix ?? []).isNotEmpty) {
      query = query.where('price_range', arrayContainsAny: prix!);
    }
    return query;
  }

  /// Transforme un DocumentSnapshot en Restaurant et génère logos + images.
  Restaurant _mapDocToRestaurant(DocumentSnapshot doc) {
    // on récupère tout le data brut
    final raw = doc.data() as Map<String, dynamic>? ?? {};

    // on crée un Restaurant depuis le Map (il génère déjà logoUrl+imageUrls)
    // merci à Restaurant.fromMap qui contient la logique media
    return Restaurant.fromFirestore(doc);
  }
}
