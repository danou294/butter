// lib/screens/search/filters/moment_filter.dart

import 'package:flutter/material.dart';

// TODO : adapte ces constantes à ta charte graphique
const _selectedBg = Color(0xFFBFB9A4);
const _unselectedBg = Color(0xFFF5F5F0);
const _labelColor = Colors.black;
const _fontFamilySans = 'InriaSans';
const double _chipHeight = 36.0;
const double _horizontalPadding = 12.0;
const double _spacing = 12.0;

typedef OnToggle = void Function(String label, bool selected);

class MomentFilter extends StatefulWidget {
  final OnToggle onToggle;
  const MomentFilter({Key? key, required this.onToggle}) : super(key: key);

  @override
  _MomentFilterState createState() => _MomentFilterState();
}

class _MomentFilterState extends State<MomentFilter> {
  final Map<String, bool> _selected = {
    'Petit-déjeuner': false,
    'Brunch': false,
    'Déjeuner': false,
    'Goûter': false,
    'Drinks': false,
    'Dîner': false,
    'Apéro': false,
    'Brunch le samedi': false,
    'Brunch le dimanche': false,
  };

  Widget _buildChip(String label) {
    final isSelected = _selected[label]!;
    return GestureDetector(
      onTap: () {
        final nowSel = !isSelected;
        setState(() => _selected[label] = nowSel);
        widget.onToggle(label, nowSel);
      },
      child: Container(
        height: _chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _selectedBg : _unselectedBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: _fontFamilySans,
            fontSize: 14,
            color: _labelColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keys = _selected.keys.toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Trois lignes de 3 items chacune
          for (var row = 0; row < 3; row++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (col) {
                final idx = row * 3 + col;
                final label = keys[idx];
                return Padding(
                  padding: EdgeInsets.only(left: col == 0 ? 0 : _spacing),
                  child: _buildChip(label),
                );
              }),
            ),
            if (row < 2) const SizedBox(height: _spacing),
          ],
        ],
      ),
    );
  }
}
