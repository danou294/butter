import 'package:flutter/material.dart';

import 'home_page.dart';
import 'favorites_page.dart';
import 'search.dart';
import 'profile_page.dart'; // ← assure-toi que ce fichier existe

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const FavoritesPage(),
    const ProfilePage(), // ← nouvelle page au lieu du logout
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 90,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, 'Explorer', 'Explorer'),
            _buildNavItem(1, 'Rechercher', 'rechercher'),
            _buildNavItem(2, 'Favoris', 'favoris'),
            _buildNavItem(3, 'Compte', 'compte'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String assetBaseName) {
    final bool isSelected = _selectedIndex == index;
    final String assetName = isSelected
        ? 'assets/navigation-tools/${assetBaseName}_black.png'
        : 'assets/navigation-tools/$assetBaseName.png';

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: 95,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetName,
              width: 32,
              height: 32,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'InriaSans',
                fontSize: 14,
                color: Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
