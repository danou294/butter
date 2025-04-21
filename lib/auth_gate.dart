import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/main_navigation.dart';      // Onglets (Home / Compte)
import 'screens/welcome_landing.dart';      // Page de bienvenue (non connecté)

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainNavigation(); // ✅ Connecté → accueil principal
        } else {
          return const WelcomeLanding(); // ❌ Pas connecté → écran d’entrée
        }
      },
    );
  }
}
