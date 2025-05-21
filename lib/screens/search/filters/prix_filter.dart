// lib/screens/search/filters/prix_filter.dart

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

class PrixFilter extends StatefulWidget {
  final OnToggle onToggle;
  const PrixFilter({Key? key, required this.onToggle}) : super(key: key);

  @override
  _PrixFilterState createState() => _PrixFilterState();
}

class _PrixFilterState extends State<PrixFilter> {
  final List<String> _options = const ['€', '€€', '€€€', '€€€€'];
  String? _selected;

  Widget _buildChip(String label) {
    final isSelected = _selected == label;
    return GestureDetector(
      onTap: () {
        final nowSel = !isSelected;
        setState(() => _selected = nowSel ? label : null);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Ligne 1 : 2 premiers
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip(_options[0]),
              const SizedBox(width: _spacing),
              _buildChip(_options[1]),
            ],
          ),
          const SizedBox(height: _spacing),
          // Ligne 2 : 2 suivants
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChip(_options[2]),
              const SizedBox(width: _spacing),
              _buildChip(_options[3]),
            ],
          ),
        ],
      ),
    );
  }
}
