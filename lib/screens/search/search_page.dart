// lib/screens/search/search_page.dart

import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import '../../services/search_service.dart';
import 'search_header.dart';
import 'search_tabs.dart';
import 'filters/localization_filter.dart';
import 'filters/moment_filter.dart';
import 'filters/cuisine_filter.dart';
import 'filters/lieu_filter.dart';
import 'filters/ambiance_filter.dart';
import 'filters/prix_filter.dart';
import 'filters/restrictions_filter.dart';
import '../search_results_page.dart';

const String _fontFamily = 'InriaSans';
const Color _filterBgUnselected = Color(0xFFF5F5F0);

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const sections = [
    'Localisation','Moment','Cuisine','Lieu',
    'Ambiance','Prix','Restrictions'
  ];

  final Set<String> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sections.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFilterToggled(String label, bool selected) {
    setState(() {
      if (selected) _selectedFilters.add(label);
      else _selectedFilters.remove(label);
    });
  }

  Future<void> _executeSearch() async {
    final dirs = <String>[];
    final arrs = <String>[];
    final moms = <String>[];
    final cuis = <String>[];
    final lieux = <String>[];
    final ambs = <String>[];
    final rest = <String>[];
    String? prix;

    for (var f in _selectedFilters) {
      if (['Ouest','Centre','Est'].contains(f)) dirs.add(f);
      else if (f.endsWith('e') && f.length<=3) arrs.add(f);
      else if (['€','€€','€€€','€€€€'].contains(f)) prix = f;
      else if (['Classique','Intimiste/tamisé','Festif','Date'].contains(f)) ambs.add(f);
      else if (['Dans la rue','Dans une galerie','Dans un musée','Dans un monument','Dans un hôtel','Other'].contains(f)) lieux.add(f);
      else if ([
        'Africain','Américain','Chinois','Coréen','Français',
        'Grec','Indien','Israélien','Italien','Japonais',
        'Libanais','Mexicain','Oriental','Péruvien',
        'Sud-Américain','Thaï','Vietnamien'
      ].contains(f)) cuis.add(f);
      else if ([
        'Petit-déjeuner','Brunch','Déjeuner','Goûter',
        'Drinks','Dîner','Apéro','Brunch le samedi','Brunch le dimanche'
      ].contains(f)) moms.add(f);
      else if ([
        'Casher (certifié)',
        'Casher friendly (tout est casher mais pas de teouda)',
        'Viande casher','Végétarien','Vegan'
      ].contains(f)) rest.add(f);
    }

    final results = await SearchService().search(
      directions: dirs,
      arrondissements: arrs,
      cuisines: cuis,
      ambiances: ambs,
      lieux: lieux,
      prixLevel: prix,
      restrictions: rest,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(results: results),
      ),
    );
  }

  Widget _buildTabView(String section) {
    switch (section) {
      case 'Localisation': return LocalizationFilter(onToggle: _onFilterToggled);
      case 'Moment':       return MomentFilter(onToggle: _onFilterToggled);
      case 'Cuisine':      return CuisineFilter(onToggle: _onFilterToggled);
      case 'Lieu':         return LieuFilter(onToggle: _onFilterToggled);
      case 'Ambiance':     return AmbianceFilter(onToggle: _onFilterToggled);
      case 'Prix':         return PrixFilter(onToggle: _onFilterToggled);
      case 'Restrictions': return RestrictionsFilter(onToggle: _onFilterToggled);
      default:             return Center(child: Text('Filtre $section'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        const SearchHeader(),
        SearchTabs(controller: _tabController, sections: sections),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: sections.map(_buildTabView).toList(),
          ),
        ),
        if (_selectedFilters.isNotEmpty) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedFilters.map((label) {
                return Chip(
                  label: Text(label, style: const TextStyle(fontFamily: _fontFamily)),
                  backgroundColor: const Color(0xFFBFB9A4),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _onFilterToggled(label, false),
                );
              }).toList(),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _selectedFilters.clear()),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _filterBgUnselected,
                  side: const BorderSide(color: Colors.black12),
                  padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Réinitialiser',
                  style: TextStyle(fontFamily: _fontFamily,fontSize: 16,color: Colors.black)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _executeSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Voir les résultats',
                  style: TextStyle(fontFamily: _fontFamily,fontSize: 16,color: Colors.white)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
