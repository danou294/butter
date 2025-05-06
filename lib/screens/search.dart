import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<String> sections = [
    'Localisation', 'Moment', 'Cuisine', 'Lieu', 'Ambiance', 'Prix', 'Restrictions'
  ];

  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  // Fonction pour centrer la section cliquée
  void _onSectionTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Défilement de la section au centre
    double position = 0;
    for (int i = 0; i < index; i++) {
      position += 100;  // Ajuste selon la taille de chaque section
    }
    _scrollController.animateTo(position, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(  // Utilisation de SingleChildScrollView pour éviter le débordement
        child: Column(
          children: [
            _buildHeader(context),
            // La barre des sections
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onSectionTapped(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sections[index],
                            style: TextStyle(
                              fontFamily: 'InriaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedIndex == index
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                          if (_selectedIndex == index)
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 30,
                              height: 3,
                              color: Colors.black,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Les filtres ou contenu de la section activée
            SizedBox(
              height: screenHeight * 0.5, // Juste un exemple de taille pour chaque section
              child: ListView.builder(
                controller: _scrollController,
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sections[index],
                          style: TextStyle(
                            fontFamily: 'InriaSerif',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Exemples de filtres pour chaque section (à adapter)
                        Container(
                          height: 60, // Taille d'exemple pour les filtres
                          color: Colors.grey[200],
                          child: Center(child: Text('Filtre ${sections[index]}')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenHeight * 0.15;

    return Container(
      height: headerHeight,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background-liste.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 10,
            left: 10,
            child: SizedBox(
              width: screenWidth * 0.23,
              height: screenHeight * 0.23,
              child: Image.asset(
                'assets/images/LogoName.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
