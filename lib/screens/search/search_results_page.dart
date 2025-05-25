// lib/screens/search/search_results_page.dart

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';
import '../services/search_service.dart';
import 'search_page.dart';
import 'restaurant_detail_page.dart';

class SearchResultsPage extends StatefulWidget {
  /// Résultats déjà récupérés via SearchPage
  final List<Restaurant> initialResults;
  /// Paramètres de filtre à réutiliser pour la pagination (si nécessaire)
  final SearchFilters filters;

  const SearchResultsPage({
    Key? key,
    required this.initialResults,
    required this.filters,
  }) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  static const _pageSize = 20;

  final SearchService _searchService = SearchService();
  final PagingController<int, Restaurant> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    // Injecter les résultats initiaux en première page
    _pagingController.appendPage(widget.initialResults, widget.initialResults.length);
    // Listener pour charger les pages suivantes
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // Requête paginée : on réutilise les mêmes filtres,
      // et on passe pageKey comme offset (qui peut être ignoré si Firestore)
      final newResults = await _searchService.search(
        zones:           widget.filters.zones,
        arrondissements: widget.filters.arrondissements,
        communes:        widget.filters.communes,
        moments:         widget.filters.moments,
        lieux:           widget.filters.lieux,
        cuisines:        widget.filters.cuisines,
        prix:            widget.filters.prix,
        // TODO: ajouter offset/limit si le service le gère
      );
      final isLast = newResults.length < _pageSize;
      if (isLast) {
        _pagingController.appendLastPage(newResults);
      } else {
        final nextKey = pageKey + newResults.length;
        _pagingController.appendPage(newResults, nextKey);
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    final headerH = screenH * 0.3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(headerH, screenW)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          PagedSliverGrid<int, Restaurant>(
            pagingController: _pagingController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.66,
            ),
            builderDelegate: PagedChildBuilderDelegate<Restaurant>(
              itemBuilder: (ctx, resto, idx) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailPage(restaurant: resto),
                    ),
                  ),
                  child: RestaurantCard(restaurant: resto),
                ),
              ),
              firstPageProgressIndicatorBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              newPageProgressIndicatorBuilder: (_) =>
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              noItemsFoundIndicatorBuilder: (_) =>
                  const Center(child: Text('Aucun résultat trouvé')),
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
        color: Colors.black.withOpacity(0.54),
        padding: const EdgeInsets.only(bottom: 20),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: width * 0.55,
                    height: height * 0.12,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacement(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Résultats',
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${_pagingController.itemList?.length ?? 0} ' +
                  ((_pagingController.itemList?.length ?? 0) > 1
                      ? 'adresses trouvées'
                      : 'adresse trouvée'),
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
}

/// Conteneur des filtres à passer à SearchResultsPage
/// pour pouvoir relancer la search-service sur les pages suivantes.
class SearchFilters {
  final List<String>? zones;
  final List<String>? arrondissements;
  final List<String>? communes;
  final List<String>? moments;
  final List<String>? lieux;
  final List<String>? cuisines;
  final List<String>? prix;

  const SearchFilters({
    this.zones,
    this.arrondissements,
    this.communes,
    this.moments,
    this.lieux,
    this.cuisines,
    this.prix,
  });
}
