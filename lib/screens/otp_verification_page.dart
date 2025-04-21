import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'welcome_page.dart'; // Crée cette page avec un simple "Bienvenue"

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String prenom;
  final String dateNaissance;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.prenom,
    required this.dateNaissance,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _codeController = TextEditingController();
  final _authService = AuthService();
  final _userService = UserService();
  bool _loading = false;

  void _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      _showSnack('Code invalide');
      return;
    }

    setState(() => _loading = true);

    try {
      // Connexion Firebase avec le code OTP
      await _authService.signInWithOTP(widget.verificationId, code);

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final uid = user.uid;

        // Enregistrement Firestore si l'utilisateur n'existe pas encore
        final exists = await _userService.userExists(uid);
        if (!exists) {
          await _userService.createUser(
            uid: uid,
            phone: widget.phoneNumber,
            prenom: widget.prenom,
            dateNaissance: widget.dateNaissance,
          );
        }

        // Navigation vers l'accueil ou page de bienvenue
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WelcomePage(prenom: widget.prenom),
            ),
          );
        }
      } else {
        _showSnack('Utilisateur introuvable après vérification.');
      }
    } catch (e) {
      _showSnack('Code incorrect ou expiré ❌');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'BUTTER',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
            color: Colors.black,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Entre le code reçu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Code de vérification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _codeController,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeColor: Colors.black,
                      inactiveColor: Colors.grey,
                      selectedColor: Colors.black87,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _loading ? null : _verifyCode,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Valider',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
