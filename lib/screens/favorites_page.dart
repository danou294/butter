// lib/screens/favorites_page.dart
import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';
import 'main_navigation.dart';
import 'restaurant_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();
  final RestaurantService _restaurantService = RestaurantService();

  List<Restaurant> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await _favoriteService.getFavoriteRestaurantIds();

    // 1) Load from cache
    final cached = await _restaurantService.fetchFromCache();
    final fromCache = cached.where((r) => ids.contains(r.id)).toList();
    if (mounted) {
      setState(() {
        _favorites = fromCache;
        _loading = false;
      });
    }

    // 2) Load from network
    final fresh = await _restaurantService.fetchFromNetwork();
    final fromNetwork = fresh.where((r) => ids.contains(r.id)).toList();
    if (mounted) {
      setState(() {
        _favorites = fromNetwork;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenHeight * 0.3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(headerHeight, screenWidth),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          _loading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverToBoxAdapter(child: _buildSplitColumns()),
        ],
      ),
    );
  }

  Widget _buildHeader(double height, double width) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background-liste.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        color: Colors.black54,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderButton(width, height),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Mes favoris',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InriaSerif',
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  '${_favorites.length} ' +
                      (_favorites.length > 1 ? 'adresses enregistrées' : 'adresse enregistrée'),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: height * 0.06,
                    fontFamily: 'InriaSans',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(double width, double height) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: SizedBox(
          width: width * 0.55,
          height: height * 0.12,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigation()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                fontSize: height * 0.035,
                fontFamily: 'InriaSans',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Découvrir des nouvelles adresses'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitColumns() {
    final left = <Widget>[];
    final right = <Widget>[];

    for (int i = 0; i < _favorites.length; i++) {
      final item = Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailPage(restaurant: _favorites[i]),
            ),
          ),
          child: RestaurantCard(restaurant: _favorites[i]),
        ),
      );
      if (i.isEven) {
        left.add(item);
      } else {
        right.add(item);
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