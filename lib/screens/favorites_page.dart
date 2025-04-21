import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _favoriteService = FavoriteService();
  final _restaurantService = RestaurantService();

  List<Restaurant> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await _favoriteService.getFavoriteRestaurantIds();

    // Charger depuis le cache d'abord (affichage rapide)
    final cached = await _restaurantService.loadCachedRestaurants();
    final filteredCached = cached.where((r) => ids.contains(r.id)).toList();
    setState(() {
      _favorites = filteredCached;
      _loading = false;
    });

    // Puis mise à jour des données en arrière-plan
    final fresh = await _restaurantService.fetchRestaurants();
    final filteredFresh = fresh.where((r) => ids.contains(r.id)).toList();
    setState(() {
      _favorites = filteredFresh;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        title: const Text("Mes favoris"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text("Aucun favori pour l’instant."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 2,
                    children: _favorites
                        .map((restaurant) =>
                            RestaurantCard(restaurant: restaurant))
                        .toList(),
                  ),
                ),
    );
  }
}
