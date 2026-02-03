import 'package:flutter/material.dart';
import '../utils/encryption_utils.dart';

class SecretPage extends StatelessWidget {
  final String code;
  final String encryptedTitle;
  final String encryptedCode;

  const SecretPage({
    super.key,
    required this.code,
    required this.encryptedTitle,
    required this.encryptedCode,
  });

  @override
  Widget build(BuildContext context) {
    final title = EncryptionUtils.decryptText(encryptedTitle, code);
    final secretCode = EncryptionUtils.decryptText(encryptedCode, code);

    if (title == null || secretCode == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Errore di decriptazione. Accesso negato.',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade900, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  secretCode,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 24,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Torna Indietro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
