import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'otp_verification_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _prenomController = TextEditingController();
  final _dateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;

  void _onSuivantPressed() async {
    final phone = _phoneController.text.trim().replaceAll(' ', '');

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
              builder: (context) => OTPVerificationPage(
                phoneNumber: phone,
                verificationId: verificationId,
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

  bool _isValidPhone(String phone) {
    return phone.startsWith('+') && phone.length >= 10;
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Devenir membre',
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
                children: [
                  TextField(
                    controller: _prenomController,
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date de naissance',
                      hintText: 'JJ/MM/AAAA',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      hintText: '+33 X XX XX XX XX',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
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
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Suivant',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 2, width: 40, color: Colors.black12),
                const SizedBox(width: 6),
                Container(height: 2, width: 40, color: Colors.black),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
