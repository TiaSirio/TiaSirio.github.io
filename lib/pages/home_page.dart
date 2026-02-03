import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../utils/encryption_utils.dart';
import 'secret_page.dart';
import 'dart:html' as html;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorMessage;
  String? _encryptedTitle;
  String? _encryptedCode;
  bool _isLoading = true;

  // Asset paths
  final String _typingImg = 'assets/imgs/typing.png';
  final String _correctImg = 'assets/imgs/correct.png';
  final String _wrongImg = 'assets/imgs/wrong.png';
  
  String? _currentImg;

  @override
  void initState() {
    super.initState();
    // Initially image is hidden
    _currentImg = null;
    _loadSecrets();
    
    // Listen to text changes
    _codeController.addListener(() {
      // Show image on first non-empty input
      if (_currentImg == null && _codeController.text.isNotEmpty) {
        setState(() {
          _currentImg = _typingImg;
        });
      } 
      // Reset image to typing when user edits after show
      else if (_currentImg != null && _currentImg != _typingImg) {
        setState(() {
          _currentImg = _typingImg;
          _errorMessage = null;
        });
      }
    });
  }

  Future<void> _loadSecrets() async {
    try {
      final String response = await rootBundle.loadString('assets/secrets/secrets.json');
      final data = await json.decode(response);
      setState(() {
        _encryptedTitle = data['title'];
        _encryptedCode = data['code'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore nel caricamento dei segreti';
        _isLoading = false;
      });
    }
  }

  void _downloadFile() {
    // Scarica il file dagli assets locali del progetto
    const assetPath = 'assets/assets/secrets/listen.txt';
    html.AnchorElement(href: assetPath)
      ..setAttribute('download', 'listen.txt')
      ..click();
  }

  void _confirmCode() {
    if (_isLoading || _encryptedTitle == null) return;

    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Inserisci il codice';
        _currentImg = _wrongImg;
      });
      return;
    }

    final decoded = EncryptionUtils.decryptText(_encryptedTitle!, code);

    if (decoded != null) {
      setState(() {
        _errorMessage = null;
        _currentImg = _correctImg;
      });
      
      // Delay navigation slightly to let the user see the "correct" image
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SecretPage(
                code: code,
                encryptedTitle: _encryptedTitle!,
                encryptedCode: _encryptedCode!,
              ),
            ),
          );
        }
      });
    } else {
      setState(() {
        _errorMessage = 'Codice errato';
        _currentImg = _wrongImg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
        backgroundColor: Color(0xFF1A237E),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.indigo.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(32),
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withAlpha(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dynamic Image with smooth transition
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: _currentImg != null 
                        ? Image.asset(
                            _currentImg!,
                            key: ValueKey<String>(_currentImg!),
                            height: 250,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox.shrink(key: ValueKey<String>('placeholder')),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.lock, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Accesso Riservato',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _downloadFile,
                    icon: const Icon(Icons.download),
                    label: const Text('Scarica Allegato'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _codeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Inserisci Codice',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      errorText: _errorMessage,
                      errorStyle: const TextStyle(color: Colors.orangeAccent),
                    ),
                    onSubmitted: (_) => _confirmCode(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _confirmCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Conferma'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
