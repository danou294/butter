class Restaurant {
  final String id;
  final String vraiNom;
  final String arrondissement;
  final String typeCuisine;
  final String prix;
  final String tag;
  List<String> photoUrls;

  Restaurant({
    required this.id,
    required this.vraiNom,
    required this.arrondissement,
    required this.typeCuisine,
    required this.prix,
    required this.tag,
    this.photoUrls = const [],
  });

  factory Restaurant.fromFirestore(Map<String, dynamic> data, String docId) {
    return Restaurant(
      id: docId,
      vraiNom: data['vrai_nom'] ?? '',
      arrondissement: data['arrondissement'] ?? '',
      typeCuisine: data['type_cuisine'] ?? '',
      prix: data['prix'] ?? '',
      tag: data['tag'] ?? '',
    );
  }
}
