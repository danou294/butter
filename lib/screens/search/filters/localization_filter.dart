// lib/screens/search/filters/localization_filter.dart

import 'package:flutter/material.dart';

// TODO : adapte ces constantes à ta charte graphique
const _selectedBg = Color(0xFFBFB9A4);
const _unselectedBg = Color(0xFFF5F5F0);
const _labelColor = Colors.black;
const _fontFamilySans = 'InriaSans';

// Ajustements de taille
const double _dirSize = 78.0;         // largeur & hauteur du bouton direction
const double _dirIconScale = 0.5;     // échelle de l’icône
const double _dirLabelSize = 12.0;    // taille du texte sous l’icône
const double _dirSpacing = 4.0;       // espacement entre icône et label

const double _arrSize = 38.0;         // taille des carrés arrondissements
const double _arrFontSize = 12.0;     // taille du texte dans arrondissements

const double _communeWidth = 78.0;    // largeur des boutons communes
const double _communeHeight = 36.0;   // hauteur des boutons communes
const double _communeFontSize = 12.0; // taille du texte dans communes

typedef OnToggle = void Function(String label, bool selected);

class LocalizationFilter extends StatefulWidget {
  final OnToggle onToggle;
  const LocalizationFilter({Key? key, required this.onToggle}) : super(key: key);

  @override
  _LocalizationFilterState createState() => _LocalizationFilterState();
}

class _LocalizationFilterState extends State<LocalizationFilter> {
  // Directions (multi-sélection)
  final List<_DirectionItem> _directions = const [
    _DirectionItem('Ouest', 'assets/direction/ouest.png'),
    _DirectionItem('Centre', 'assets/direction/centre.png'),
    _DirectionItem('Est',   'assets/direction/est.png'),
  ];
  final Set<int> _selectedDirections = {};

  // Arrondissements (multi-sélection)
  final List<String> _arr = List.generate(20, (i) => '${i + 1}e');
  final Set<String> _selectedArrondissements = {};

  // Communes (multi-sélection)
  final List<String> _communes = [
    'Boulogne', 'Levallois', 'Neuilly',
    'Charenton', 'Saint-Mandé', 'Saint-Ouen',
    'Saint-Cloud',
  ];
  final Set<String> _selectedCommunes = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1) Directions : icône + légende, centrées
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _directions.asMap().entries.map((entry) {
                final idx = entry.key;
                final dir = entry.value;
                final isSel = _selectedDirections.contains(idx);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () {
                      final nowSel = !isSel;
                      setState(() {
                        if (isSel) _selectedDirections.remove(idx);
                        else _selectedDirections.add(idx);
                      });
                      widget.onToggle(dir.label, nowSel);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: _dirSize,
                          height: _dirSize,
                          decoration: BoxDecoration(
                            color: isSel ? _selectedBg : _unselectedBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Image.asset(
                              dir.assetPath,
                              width: _dirSize * _dirIconScale,
                              height: _dirSize * _dirIconScale,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: _dirSpacing),
                        Text(
                          dir.label,
                          style: TextStyle(
                            fontFamily: _fontFamilySans,
                            fontSize: _dirLabelSize,
                            color: _labelColor,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // 2) Arrondissements
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: _arr.map((e) {
              final isSel = _selectedArrondissements.contains(e);
              return GestureDetector(
                onTap: () {
                  final nowSel = !isSel;
                  setState(() {
                    if (isSel) _selectedArrondissements.remove(e);
                    else _selectedArrondissements.add(e);
                  });
                  widget.onToggle(e, nowSel);
                },
                child: Container(
                  width: _arrSize,
                  height: _arrSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? _selectedBg : _unselectedBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    e,
                    style: TextStyle(
                      fontFamily: _fontFamilySans,
                      fontSize: _arrFontSize,
                      color: _labelColor,
                      fontWeight:
                          isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 3) Communes
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: _communes.map((e) {
              final isSel = _selectedCommunes.contains(e);
              return GestureDetector(
                onTap: () {
                  final nowSel = !isSel;
                  setState(() {
                    if (isSel) _selectedCommunes.remove(e);
                    else _selectedCommunes.add(e);
                  });
                  widget.onToggle(e, nowSel);
                },
                child: Container(
                  width: _communeWidth,
                  height: _communeHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? _selectedBg : _unselectedBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    e,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: _fontFamilySans,
                      fontSize: _communeFontSize,
                      color: _labelColor,
                      fontWeight:
                          isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DirectionItem {
  final String label;
  final String assetPath;
  const _DirectionItem(this.label, this.assetPath);
}
