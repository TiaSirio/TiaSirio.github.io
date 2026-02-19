import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const RiddleApp());
}

class RiddleApp extends StatelessWidget {
  const RiddleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Il Gioco del Regalo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const GameContainer(),
    );
  }
}

class GameContainer extends StatefulWidget {
  const GameContainer({super.key});

  @override
  State<GameContainer> createState() => _GameContainerState();
}

class _GameContainerState extends State<GameContainer> {
  List<dynamic> _riddles = [];
  Map<String, dynamic>? _conclusion;
  int _currentIndex = -1; // -1 for Intro, >=0 for riddles, riddles.length for Conclusion
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/riddles.json');
      final data = await json.decode(response);
      setState(() {
        _riddles = data['riddles'];
        _conclusion = data['conclusion'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading JSON: $e");
    }
  }

  void _startGame() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void _nextStep() {
    setState(() {
      _currentIndex++;
    });
  }

  void _restart() {
    setState(() {
      _currentIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundBlobs(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GlassCard(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _buildCurrentScreen(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    if (_currentIndex == -1) {
      return IntroScreen(onStart: _startGame);
    } else if (_currentIndex < _riddles.length) {
      return RiddleScreen(
        riddle: _riddles[_currentIndex],
        index: _currentIndex,
        total: _riddles.length,
        onCorrect: _nextStep,
        key: ValueKey(_currentIndex),
      );
    } else {
      return ConclusionScreen(
        conclusion: _conclusion!,
        onRestart: _restart,
      );
    }
  }
}

class BackgroundBlobs extends StatelessWidget {
  const BackgroundBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: _Blob(color: Colors.indigo.withOpacity(0.3), size: 400),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _Blob(color: Colors.lightBlue.withOpacity(0.3), size: 500),
        ),
        Center(
          child: _Blob(color: Colors.deepPurple.withOpacity(0.2), size: 300),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          constraints: const BoxConstraints(maxWidth: 600),
          child: child,
        ),
      ),
    );
  }
}

class IntroScreen extends StatelessWidget {
  final VoidCallback onStart;
  const IntroScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF818CF8), Color(0xFF2DD4BF)],
          ).createShader(bounds),
          child: Text(
            'Il Gioco del Regalo',
            style: GoogleFonts.outfit(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Benvenuto al gioco del regalo. Preparati a risolvere gli indovinelli per trovare la tua sorpresa.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Inizia la Sfida', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class RiddleScreen extends StatefulWidget {
  final dynamic riddle;
  final int index;
  final int total;
  final VoidCallback onCorrect;

  const RiddleScreen({
    super.key,
    required this.riddle,
    required this.index,
    required this.total,
    required this.onCorrect,
  });

  @override
  State<RiddleScreen> createState() => _RiddleScreenState();
}

class _RiddleScreenState extends State<RiddleScreen> {
  final TextEditingController _controller = TextEditingController();
  String _feedback = '';
  bool _isError = false;

  String _normalize(String input) {
    return input.toLowerCase().replaceAll(' ', '').replaceAll('&', 'and');
  }

  void _checkAnswer() {
    final userAnswer = _normalize(_controller.text.trim());
    final dynamic solutionData = widget.riddle['solution'];

    bool isCorrect = false;

    if (solutionData is String) {
      isCorrect = userAnswer == _normalize(solutionData);
    } else if (solutionData is List) {
      // Se è una lista, ci aspettiamo che sia una lista di gruppi di alternative.
      // Ogni gruppo deve avere almeno una parola chiave presente nella risposta.
      isCorrect = solutionData.every((group) {
        if (group is List) {
          return group.any((alt) => userAnswer.contains(_normalize(alt.toString())));
        }
        // Se l'elemento della lista non è una lista, deve essere contenuto nella risposta
        return userAnswer.contains(_normalize(group.toString()));
      });
    }

    if (isCorrect) {
      setState(() {
        _feedback = 'Risposta Corretta!';
        _isError = false;
      });
      Future.delayed(const Duration(seconds: 1), widget.onCorrect);
    } else {
      setState(() {
        _feedback = 'Risposta Sbagliata!';
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: widget.index / widget.total,
          backgroundColor: Colors.white.withOpacity(0.05),
          valueColor: const AlwaysStoppedAnimation(Color(0xFF6366F1)),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 32),
        Text(
          widget.riddle['title'],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          widget.riddle['question'],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, height: 1.6),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Scrivi la tua soluzione...',
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
          onSubmitted: (_) => _checkAnswer(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Invia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _feedback,
          style: TextStyle(
            color: _isError ? Colors.redAccent : Colors.greenAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ConclusionScreen extends StatelessWidget {
  final Map<String, dynamic> conclusion;
  final VoidCallback onRestart;

  const ConclusionScreen({
    super.key,
    required this.conclusion,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/imgs/gift.png',
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          conclusion['text'],
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2DD4BF),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 20,
          children: (conclusion['signatures'] as List).map((name) {
            return Text(
              name,
              style: GoogleFonts.caveat(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF818CF8),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 48),
        TextButton(
          onPressed: onRestart,
          child: const Text(
            'Ricomincia',
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
