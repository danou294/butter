class Restaurant {
  final String nom;
  final String arrondissement;
  final String typeCuisine;
  final String prix;
  final List<String> photoUrls;

  Restaurant({
    required this.nom,
    required this.arrondissement,
    required this.typeCuisine,
    required this.prix,
    required this.photoUrls,
  });

  factory Restaurant.fromMap(Map<String, dynamic> data) {
    return Restaurant(
      nom: data['nom'] ?? '',
      arrondissement: data['arrondissement'] ?? '',
      typeCuisine: data['type_cuisine'] ?? '',
      prix: data['prix'] ?? '',
      photoUrls: List<String>.from(data['photo_urls'] ?? []),
    );
  }
}
