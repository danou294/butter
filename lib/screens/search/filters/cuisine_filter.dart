// lib/screens/search/filters/cuisine_filter.dart

import 'package:flutter/material.dart';

// TODO : adapte ces constantes à ta charte graphique
const _selectedBg = Color(0xFFBFB9A4);
const _unselectedBg = Color(0xFFF5F5F0);
const _labelColor = Colors.black;
const _fontFamilySans = 'InriaSans';
const double _chipHeight = 32.0;
const double _horizontalPadding = 12.0;
const double _verticalSpacing = 12.0;

typedef OnToggle = void Function(String label, bool selected);

class CuisineFilter extends StatefulWidget {
  final OnToggle onToggle;
  const CuisineFilter({Key? key, required this.onToggle}) : super(key: key);

  @override
  _CuisineFilterState createState() => _CuisineFilterState();
}

class _CuisineFilterState extends State<CuisineFilter> {
  final Map<String, bool> _selected = {
    'Italien': false,
    'Méditerranéen': false,
    'Asiatique': false,
    'Sud Américain': false,
    'Français': false,
    'Indien': false,
    'Américain': false,
    'Africain': false,
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
          style: TextStyle(
            fontFamily: _fontFamilySans,
            fontSize: 13,
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
      padding: const EdgeInsets.symmetric(vertical: _verticalSpacing),
      child: Column(
        children: [
          // Première ligne : 3 items
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip(keys[0]),
              const SizedBox(width: _verticalSpacing),
              _buildChip(keys[1]),
              const SizedBox(width: _verticalSpacing),
              _buildChip(keys[2]),
            ],
          ),
          const SizedBox(height: _verticalSpacing),

          // Deuxième ligne : 3 items
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip(keys[3]),
              const SizedBox(width: _verticalSpacing),
              _buildChip(keys[4]),
              const SizedBox(width: _verticalSpacing),
              _buildChip(keys[5]),
            ],
          ),
          const SizedBox(height: _verticalSpacing),

          // Troisième ligne : 2 items centrés
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip(keys[6]),
              const SizedBox(width: _verticalSpacing),
              _buildChip(keys[7]),
            ],
          ),
        ],
      ),
    );
  }
}
