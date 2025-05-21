// lib/screens/search/search_results_page.dart

import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_detail_page.dart';
import 'main_navigation.dart';

class SearchResultsPage extends StatelessWidget {
  final List<Restaurant> results;

  const SearchResultsPage({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final headerH = screenH * 0.3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // En-tête avec image de fond et titre
          SliverToBoxAdapter(
            child: _buildHeader(headerH, screenW, context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          // Contenu : message si vide, sinon grille en deux colonnes
          if (results.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Aucun résultat trouvé',
                  style: TextStyle(
                    fontFamily: 'InriaSans',
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(child: _buildSplitColumns(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(double height, double width, BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background-liste.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.only(bottom: 20),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton pour retourner modifier les filtres
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: SizedBox(
                    width: width * 0.55,
                    height: height * 0.12,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainNavigation(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontFamily: 'InriaSans',
                          fontSize: height * 0.035,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Modifier mes filtres'),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              // Titre
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Résultats',
                  style: TextStyle(
                    fontFamily: 'InriaSerif',
                    fontSize: height * 0.12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Nombre de résultats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  '${results.length} ' +
                      (results.length > 1 ? 'adresses trouvées' : 'adresse trouvée'),
                  style: TextStyle(
                    fontFamily: 'InriaSans',
                    fontSize: height * 0.06,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitColumns(BuildContext context) {
    final left = <Widget>[];
    final right = <Widget>[];

    for (var i = 0; i < results.length; i++) {
      final restaurant = results[i];
      final card = Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailPage(restaurant: restaurant),
            ),
          ),
          child: RestaurantCard(restaurant: restaurant),
        ),
      );
      if (i.isEven) {
        left.add(card);
      } else {
        right.add(card);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: left)),
          const SizedBox(width: 10),
          Expanded(child: Column(children: right)),
        ],
      ),
    );
  }
}
