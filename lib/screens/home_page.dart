import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';
import 'search.dart';
import 'restaurant_detail_page.dart'; // Importation de la page RestaurantDetailPage

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
    _initApp();
  }

  Future<void> _initApp() async {
    await _restaurantService.clearCache();
    final fetchedPrenom = await _userService.fetchCurrentUserPrenom();
    setState(() => _prenom = _capitalize(fetchedPrenom ?? 'utilisateur'));

    final freshRestaurants = await _restaurantService.fetchRestaurants();
    setState(() {
      _restaurants = freshRestaurants;
      _loading = false;
    });
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
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
          SliverToBoxAdapter(child: _buildHeader(headerHeight, screenWidth)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          _loading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
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
        color: Colors.black.withOpacity(0.45),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.30,
                      height: height * 0.35,
                      child: Image.asset(
                        'assets/icon/app_icon2.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.4,
                      height: height * 0.12,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SearchPage()),
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
                          child: Text('Recherche personnalisée'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: height * 0.06,
                    fontFamily: 'InriaSerif',
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  _prenom ?? '',
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
                child: SizedBox(
                  width: width * 0.75,
                  child: Text(
                    'On t’a trouvé les meilleurs restos de Paris ;) ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: height * 0.06,
                      fontFamily: 'InriaSans',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitColumns() {
    List<Widget> leftColumn = [];
    List<Widget> rightColumn = [];

    for (int i = 0; i < _restaurants.length; i++) {
      final card = RestaurantCard(restaurant: _restaurants[i]);
      final paddedCard = Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onTap: () {
            // Naviguer vers la page de détails du restaurant
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RestaurantDetailPage(
                  restaurant: _restaurants[i], // Passer le restaurant sélectionné
                ),
              ),
            );
          },
          child: card,
        ),
      );

      if (i % 2 == 0) {
        leftColumn.add(paddedCard);
      } else {
        rightColumn.add(paddedCard);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: leftColumn)),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(children: rightColumn),
            ),
          ),
        ],
      ),
    );
  }
}
