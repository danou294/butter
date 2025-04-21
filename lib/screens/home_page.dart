import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _restaurantService = RestaurantService();
  final _userService = UserService();
  List<Restaurant> _restaurants = [];
  String? _prenom;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final restos = await _restaurantService.fetchRestaurants();
    final rawPrenom = await _userService.fetchCurrentUserPrenom();

    setState(() {
      _restaurants = restos;
      _prenom = _capitalize(rawPrenom ?? 'utilisateur');
    });
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
          // 🔝 Header
          Stack(
            children: [
              // 🌆 Image de fond
              Image.asset(
                'assets/images/background-liste.png',
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),

              // 🧊 Filtre noir semi-transparent
              Container(
                width: double.infinity,
                height: 220,
                color: Colors.black.withOpacity(0.45),
              ),

              // 🅱️ Logo + 🔍 bouton bien alignés en haut
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Logo aligné par le bas
                      Image.asset(
                        'assets/icon/app_icon2.png',
                        height: 90,
                      ),
                      // Bouton aligné bas aussi
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Naviguer vers recherche personnalisée
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(fontSize: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Recherche personnalisée'),
                      ),
                    ],
                  ),
                ),
              ),

              // ✏️ Texte d’accueil (en bas du header)
              Positioned(
                left: 16,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
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
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 📋 Liste des restaurants
          Expanded(
            child: _restaurants.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    scrollDirection: Axis.horizontal,
                    children: _restaurants
                        .map((r) => RestaurantCard(restaurant: r))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
