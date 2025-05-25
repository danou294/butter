// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../services/user_service.dart';
import '../widgets/restaurant_card.dart';
import 'search/search_page.dart';
import 'restaurant_detail_page.dart';

/// Page d'accueil avec pagination infinie des restaurants.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _pageSize = 20;

  final RestaurantService _restaurantService = RestaurantService();
  final UserService _userService = UserService();

  final PagingController<DocumentSnapshot?, Restaurant> _pagingController =
      PagingController<DocumentSnapshot?, Restaurant>(firstPageKey: null);

  String? _prenom;

  @override
  void initState() {
    super.initState();
    _initUser();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _initUser() async {
    final fetchedPrenom = await _userService.fetchCurrentUserPrenom();
    if (!mounted) return;
    final name = (fetchedPrenom?.trim().isNotEmpty == true)
        ? fetchedPrenom!
        : 'utilisateur';
    setState(() {
      _prenom = '${name[0].toUpperCase()}${name.substring(1)}';
    });
  }

  Future<void> _fetchPage(DocumentSnapshot? lastDoc) async {
    try {
      final result = await _restaurantService.fetchPage(
        lastDocument: lastDoc,
        pageSize: _pageSize,
      );
      if (result.lastDocument == null) {
        _pagingController.appendLastPage(result.restaurants);
      } else {
        _pagingController.appendPage(
          result.restaurants,
          result.lastDocument,
        );
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final headerHeight = height * 0.3;

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
            onPressed: () async {
              await _restaurantService.clearCache();
              _pagingController.refresh();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache vidé, liste rafraîchie !')),
                );
              }
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(headerHeight, width)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          PagedSliverGrid<DocumentSnapshot?, Restaurant>(
            pagingController: _pagingController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.66,
            ),
            builderDelegate: PagedChildBuilderDelegate<Restaurant>(
              itemBuilder: (context, resto, index) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RestaurantCard(
                  restaurant: resto,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailPage(restaurant: resto),
                    ),
                  ),
                ),
              ),
              // Loader de la première page
              firstPageProgressIndicatorBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              // Loader des pages suivantes
              newPageProgressIndicatorBuilder: (_) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator())),
              // Aucune donnée trouvée
              noItemsFoundIndicatorBuilder: (_) =>
                  const Center(child: Text('Aucun restaurant trouvé')),
              // Erreur de la première page
              firstPageErrorIndicatorBuilder: (_) =>
                  const Center(child: Text('Erreur de chargement')),
            ),
          ),
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

  Widget _buildHeaderTop(double width, double height) {
    return Padding(
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
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  }

  Widget _buildHeaderText(double height, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome',
            style: TextStyle(
              color: Colors.white70,
              fontSize: height * 0.06,
              fontFamily: 'InriaSerif',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _prenom ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: height * 0.12,
              fontWeight: FontWeight.bold,
              fontFamily: 'InriaSerif',
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: width * 0.75,
            child: Text(
              "On t'a trouvé les meilleurs restos de Paris ;)",
              style: TextStyle(
                color: Colors.white70,
                fontSize: height * 0.06,
                fontFamily: 'InriaSans',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
