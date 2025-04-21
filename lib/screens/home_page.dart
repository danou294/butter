import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RestaurantService _restaurantService = RestaurantService();
  final UserService _userService = UserService();

  List<Restaurant> _restaurants = [];
  String? _prenom;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFromCacheThenUpdate();
  }

  Future<void> _loadFromCacheThenUpdate() async {
    final cachedRestaurants = await _restaurantService.loadCachedRestaurants();
    final fetchedPrenom = await _userService.fetchCurrentUserPrenom();

    setState(() {
      _restaurants = cachedRestaurants;
      _prenom = _capitalize(fetchedPrenom ?? 'utilisateur');
      _loading = false;
    });

    final freshRestaurants = await _restaurantService.fetchRestaurants();
    setState(() {
      _restaurants = freshRestaurants;
    });
  }

  Future<void> _clearCacheAndReload() async {
    setState(() => _loading = true);
    await _restaurantService.clearCache();
    await _loadFromCacheThenUpdate();
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/background-liste.png',
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
        Container(
          width: double.infinity,
          height: 220,
          color: Colors.black.withOpacity(0.45),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/icon/app_icon2.png',
                  height: 90,
                ),
                Column(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Navigation vers la recherche personnalisée
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(fontSize: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Recherche personnalisée'),
                    ),
                    const SizedBox(height: 4),
                    OutlinedButton(
                      onPressed: _clearCacheAndReload,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(fontSize: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Vider le cache'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                _prenom ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'On t’a trouvé les meilleurs restos de Paris ;)',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2 / 2.5,
        children: _restaurants
            .map((restaurant) => RestaurantCard(restaurant: restaurant))
            .toList(),
      ),
    );
  }
}