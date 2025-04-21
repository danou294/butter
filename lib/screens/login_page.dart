import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  void _onSuivantPressed() async {
    final rawPhone = _phoneController.text.trim();
    final phone = formatPhoneNumber(rawPhone);

    if (phone.isEmpty || !_isValidPhone(phone)) {
      _showSnack('Numéro invalide, utilise +33...');
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phone,
        onCodeSent: (verificationId) {
          setState(() => _loading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPVerificationPage(
                phoneNumber: phone,
                verificationId: verificationId,
                prenom: '',
                dateNaissance: '',
              ),
            ),
          );
        },
        onVerificationCompleted: (_) {},
        onVerificationFailed: (e) {
          _showSnack('Erreur : ${e.message}');
          setState(() => _loading = false);
        },
      );
    } catch (e) {
      _showSnack('Une erreur est survenue.');
      setState(() => _loading = false);
    }
  }

  String formatPhoneNumber(String input) {
    input = input.replaceAll(' ', '').replaceAll('-', '');
    if (input.startsWith('0')) {
      return input.replaceFirst('0', '+33');
    } else if (input.startsWith('+33')) {
      return input;
    } else {
      return '';
    }
  }

  bool _isValidPhone(String phone) {
    return phone.startsWith('+33') && phone.length >= 12;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Se connecter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      hintText: '+33 X XX XX XX XX',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Un code de vérification va t’être envoyé par SMS.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
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
                onPressed: _loading ? null : _onSuivantPressed,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Suivant',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
