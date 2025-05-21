// lib/screens/search/filters/restrictions_filter.dart

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

class RestrictionsFilter extends StatefulWidget {
  final OnToggle onToggle;
  const RestrictionsFilter({Key? key, required this.onToggle}) : super(key: key);

  @override
  _RestrictionsFilterState createState() => _RestrictionsFilterState();
}

class _RestrictionsFilterState extends State<RestrictionsFilter> {
  final Map<String, bool> _selected = {
    'Casher (certifié)': false,
    'Casher friendly\n(tout est casher\nmais pas de teouda)': false,
    'Viande casher': false,
    'Végétarien': false,
    'Vegan': false,
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
    final labels = _selected.keys.toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Ligne 1 : 3 premiers items
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip(labels[0]),
              const SizedBox(width: _spacing),
              _buildChip(labels[1]),
              const SizedBox(width: _spacing),
              _buildChip(labels[2]),
            ],
          ),
          const SizedBox(height: _spacing),
          // Ligne 2 : 2 derniers items centrés
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip(labels[3]),
              const SizedBox(width: _spacing),
              _buildChip(labels[4]),
            ],
          ),
        ],
      ),
    );
  }
}
