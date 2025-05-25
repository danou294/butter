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

class RestrictionsFilter extends StatelessWidget {
  final Set<String> selected;
  final OnToggle onToggle;

  const RestrictionsFilter({
    Key? key,
    required this.selected,
    required this.onToggle,
  }) : super(key: key);

  Widget _buildChip(String label) {
    final isSelected = selected.contains(label);
    return GestureDetector(
      onTap: () => onToggle(label, !isSelected),
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
    const labels = [
      'Casher (certifié)',
      'Casher friendly\n(tout est casher\nmais pas de teouda)',
      'Viande casher',
      'Végétarien',
      'Vegan',
    ];

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
          // Ligne 2 : 2 derniers items
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
