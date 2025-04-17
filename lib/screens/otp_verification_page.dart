import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/auth_service.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  void _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showSnack('Code invalide');
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.signInWithOTP(widget.verificationId, code);
      _showSnack('Connexion réussie 🎉');
      // Redirige vers page d’accueil ici si tu veux
    } catch (e) {
      _showSnack('Code incorrect ou expiré ❌');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _resendCode() {
    // Tu peux ajouter ici la logique pour renvoyer le code avec Firebase
    _showSnack('Fonction renvoyer un code à implémenter');
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
                    obscureText: false,
                    autoFocus: true,
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
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _resendCode,
                    child: const Text(
                      'Renvoyer un code',
                      style: TextStyle(
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
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
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _loading ? null : _verifyCode,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Suivant',
                        style: TextStyle(fontSize: 16, color: Colors.white),
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
