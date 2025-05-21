import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';
import 'search/search_page.dart';
import 'restaurant_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RestaurantService _service = RestaurantService();
  final UserService _userService = UserService();

  List<Restaurant> _restaurants = [];
  String? _prenom;
  bool _loadingCache = true;
  bool _loadingNetwork = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1) Get user prenom
    final fetchedPrenom = await _userService.fetchCurrentUserPrenom();
    setState(() => _prenom = _capitalize(fetchedPrenom ?? 'utilisateur'));
    
    // 2) Load cache
    final cached = await _service.fetchFromCache();
    if (mounted) {
      setState(() {
        _restaurants = cached;
        _loadingCache = false;
      });
    }
    
    // 3) Fetch network in background
    setState(() => _loadingNetwork = true);
    final fresh = await _service.fetchFromNetwork();
    if (mounted) {
      setState(() {
        _restaurants = fresh;
        _loadingNetwork = false;
      });
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  Future<void> _viderCache() async {
    setState(() {
      _loadingCache = true;
      _loadingNetwork = false;
    });
    await _service.clearCache();
    // re-run init flow
    await _initApp();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache vidé, données rafraîchies !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final headerHeight = height * 0.3;

    final isLoading = _loadingCache || _loadingNetwork && _restaurants.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Accueil', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Vider le cache',
            onPressed: _viderCache,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(headerHeight, width)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          isLoading
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
        color: Colors.black.withOpacity(0.45),
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTop(width, height),
              _buildHeaderText(height, width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTop(double width, double height) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width * 0.3,
              child: Image.asset('assets/icon/app_icon2.png', fit: BoxFit.contain),
            ),
            SizedBox(
              width: width * 0.4,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: height * 0.035,
                    fontFamily: 'InriaSans',
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Recherche personnalisée'),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildHeaderText(double height, double width) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome', style: TextStyle(color: Colors.white70, fontSize: height * 0.06, fontFamily: 'InriaSerif')),
            const SizedBox(height: 4),
            Text(_prenom ?? '', style: TextStyle(color: Colors.white, fontSize: height * 0.12, fontWeight: FontWeight.bold, fontFamily: 'InriaSerif')),
            const SizedBox(height: 4),
            SizedBox(
              width: width * 0.75,
              child: Text("On t'a trouvé les meilleurs restos de Paris ;)", style: TextStyle(color: Colors.white70, fontSize: height * 0.06, fontFamily: 'InriaSans')),
            ),
          ],
        ),
      );

  Widget _buildSplitColumns() {
    final left = <Widget>[];
    final right = <Widget>[];
    for (var i = 0; i < _restaurants.length; i++) {
      final item = Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: RestaurantCard(
          restaurant: _restaurants[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RestaurantDetailPage(restaurant: _restaurants[i])),
          ),
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