import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  bool isFavorite = false;  // Variable pour savoir si le restaurant est dans les favoris

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: Image.asset('assets/icon/precedent.png'),  // Icon pour revenir en arrière
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Affichage des photos du restaurant côte à côte avec un slider horizontal
            Container(
              height: screenHeight * 0.4,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,  // Permet de faire défiler horizontalement
                itemCount: widget.restaurant.photoUrls.length - 1, // Ne pas inclure la première image
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),  // Ajout du borderRadius de 10
                      child: Image.network(
                        widget.restaurant.photoUrls[index + 1], // Commencer à partir de l'index 1
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Affichage du trueName en titre et bouton favoris aligné à droite
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurant.trueName,  // Affichage du trueName comme titre
                        style: TextStyle(
                          fontFamily: 'InriaSerif',  // Utilisation de la police de la charte graphique
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),  // Réduction de la marge entre trueName et restaurantType
                      Text(
                        widget.restaurant.restaurantType.join(', '),
                        style: TextStyle(
                          fontFamily: 'InriaSerif',  // Utilisation de la police pour le restaurantType
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Bouton Favoris
                      IconButton(
                        icon: Image.asset(
                          isFavorite ? 'assets/navigation-tools/favoris_black.png' : 'assets/navigation-tools/favoris.png',
                          width: 50,  // Taille des icônes égale
                          height: 50,
                        ),
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;  // Toggle the favorite status
                          });
                        },
                      ),
                      // Bouton Envoyer
                      IconButton(
                        icon: Image.asset(
                          'assets/restau-details-tools/send.png',
                          width: 50,  // Taille des icônes égale
                          height: 50,
                        ),
                        onPressed: () {
                          // Ajoute ici la fonction pour partager le restaurant si nécessaire
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
