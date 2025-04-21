import 'package:flutter/material.dart';
import 'registration_page.dart';
import 'login_page.dart';

class WelcomeLanding extends StatelessWidget {
  const WelcomeLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌆 Background
          Image.asset(
            'assets/images/background-app.png',
            fit: BoxFit.cover,
          ),

          // 🧊 Filtre sombre semi-transparent
          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          // 🌟 Contenu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'BUTTER',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Food, drinks\nand vibe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),

                  // 🔘 Devenir membre (blanc)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegistrationPage()),
                        );
                      },
                      child: const Text(
                        'Devenir membre',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔘 Continuer invité (noir)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Action invité
                      },
                      child: const Text('Continuer en tant qu’invité'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔗 Se connecter (lien)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Déjà membre ? Se connecter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 📄 Disclaimer
                  const Text(
                    'En tapant sur “Devenir membre” ou “Continuer en tant qu’invité”\n'
                    'tu acceptes nos conditions d’utilisation et politique de confidentialité',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
