import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class ConfusingLettersGame extends StatefulWidget {
  const ConfusingLettersGame({super.key});

  @override
  State<ConfusingLettersGame> createState() => _ConfusingLettersGameState();
}

class _ConfusingLettersGameState extends State<ConfusingLettersGame>
    with TickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  int _currentRound = 0;
  int _score = 0;
  final int _totalRounds = 10;
  bool _isPlaying = false;
  String _currentLetter = '';
  bool _showResult = false;
  bool _isCorrect = false;
  AnimationController? _bounceController;
  AnimationController? _shakeController;
  Animation<double>? _bounceAnimation;
  Animation<double>? _shakeAnimation;

  // Confusing letter pairs
  final List<Map<String, dynamic>> _confusingPairs = [
    {
      'pair': ['p', 'q'],
      'title': 'P and Q are tricky!',
      'emoji': '🎈',
      'hint': 'p has belly on right, q has belly on left!',
    },
    {
      'pair': ['b', 'd'],
      'title': 'B and D look alike!',
      'emoji': '🎨',
      'hint': 'b has belly on right, d has belly on left!',
    },
    {
      'pair': ['m', 'w'],
      'title': 'M and W are twins!',
      'emoji': '🏔️',
      'hint': 'm has hills going up, w has valleys going down!',
    },
    {
      'pair': ['n', 'u'],
      'title': 'N and U are similar!',
      'emoji': '🌈',
      'hint': 'n has hill going down, u has cup shape!',
    },
    {
      'pair': ['l', 'i'],
      'title': 'L and I are tall!',
      'emoji': '📏',
      'hint': 'l is tall line, i is shorter with dot!',
    },
    {
      'pair': ['o', 'a'],
      'title': 'O and A are round!',
      'emoji': '🎪',
      'hint': 'o is just circle, a has tail on right!',
    },
    {
      'pair': ['e', 'c'],
      'title': 'E and C look close!',
      'emoji': '🌙',
      'hint': 'e has line in middle, c is just curve!',
    },
    {
      'pair': ['r', 'v'],
      'title': 'R and V are pointy!',
      'emoji': '⭐',
      'hint': 'r has curve on top, v is pointy at bottom!',
    },
    {
      'pair': ['h', 'n'],
      'title': 'H and N are friends!',
      'emoji': '🎭',
      'hint': 'h has tall stem, n is shorter!',
    },
    {
      'pair': ['f', 't'],
      'title': 'F and T cross lines!',
      'emoji': '✝️',
      'hint': 'f curves down, t is straight with cross!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController!, curve: Curves.elasticOut),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController!, curve: Curves.elasticIn),
    );
    _startRound();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _bounceController?.dispose();
    _shakeController?.dispose();
    super.dispose();
  }

  void _startRound() {
    if (_currentRound >= _totalRounds) {
      setState(() {
        _showResult = true;
      });
      return;
    }

    final pair = _confusingPairs[_currentRound % _confusingPairs.length];
    final letters = pair['pair'] as List<String>;
    final randomLetter = letters[(_currentRound % 2 == 0) ? 0 : 1];

    setState(() {
      _currentLetter = randomLetter;
      _isPlaying = false;
    });

    // Speak the letter after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _playLetter(randomLetter);
    });
  }

  void _playLetter(String letter) {
    setState(() => _isPlaying = true);
    _ttsService.speak('Find the letter $letter');
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  void _checkAnswer(String selectedLetter) {
    final isCorrect = selectedLetter == _currentLetter;

    setState(() {
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _bounceController?.forward();
      _ttsService.speak('Great job! That is correct!');
      setState(() => _score += 10);
      Future.delayed(const Duration(milliseconds: 1000), () {
        _bounceController?.reset();
        setState(() => _currentRound++);
        _startRound();
      });
    } else {
      _shakeController?.forward();
      _ttsService.speak('Oops! Try again!');
      Future.delayed(const Duration(milliseconds: 800), () {
        _shakeController?.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confusing Letters Game',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF6B9D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            tooltip: 'Go to Home',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF9A9E),
              Color(0xFFFECFEF),
              Color(0xFFFFE66D),
            ],
          ),
        ),
        child: _showResult ? _buildResultScreen() : _buildGameScreen(),
      ),
    );
  }

  Widget _buildGameScreen() {
    final pair = _confusingPairs[_currentRound % _confusingPairs.length];
    final letters = pair['pair'] as List<String>;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress bar
            _buildProgressHeader(),
            const SizedBox(height: 16),

            // Fun character with speech bubble
            _buildCharacterBubble(pair),
            const SizedBox(height: 24),

            // Letters to choose from
            Expanded(
              child: _buildLetterChoices(letters),
            ),

            // Replay button
            _buildReplayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            'Score: $_score',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B9D),
            ),
          ),
          const Spacer(),
          Text(
            '${_currentRound + 1}/$_totalRounds',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterBubble(Map<String, dynamic> pair) {
    return Column(
      children: [
        // Speech bubble
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                pair['emoji'],
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                pair['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE66D).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pair['hint'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // Character
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Text(
            '🧸',
            style: TextStyle(fontSize: 48),
          ),
        ),
      ],
    );
  }

  Widget _buildLetterChoices(List<String> letters) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Tap the letter you hear!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: letters.map((letter) {
              return _buildLetterButton(letter);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterButton(String letter) {
    return GestureDetector(
      onTap: _isPlaying ? null : () => _checkAnswer(letter),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          if (_isCorrect) _bounceAnimation!,
          if (!_isCorrect) _shakeAnimation!,
        ]),
        builder: (context, child) {
          double scale = 1.0;
          double offsetX = 0.0;

          if (_isCorrect && _bounceAnimation != null) {
            scale = 1.0 + (_bounceAnimation!.value * 0.2);
          } else if (!_isCorrect && _shakeAnimation != null) {
            offsetX = _shakeAnimation!.value * 10 *
                (_shakeController!.status == AnimationStatus.forward ? 1 : -1);
          }

          return Transform.translate(
            offset: Offset(offsetX, 0),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: Container(
          width: 140,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                letter.toUpperCase(),
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B9D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                letter.toLowerCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplayButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: ElevatedButton.icon(
        onPressed: _isPlaying ? null : () => _playLetter(_currentLetter),
        icon: const Icon(Icons.volume_up, size: 28),
        label: const Text(
          'Listen Again',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFFF6B9D),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / (_totalRounds * 10)) * 100;
    String message = '';
    String emoji = '';

    if (percentage >= 90) {
      message = 'Amazing! You\'re a star!';
      emoji = '🌟';
    } else if (percentage >= 70) {
      message = 'Great job! Keep practicing!';
      emoji = '🎉';
    } else if (percentage >= 50) {
      message = 'Good effort! Try again!';
      emoji = '👍';
    } else {
      message = 'Keep learning! You\'ll get it!';
      emoji = '💪';
    }

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B9D),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Score: $_score / ${_totalRounds * 10}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentRound = 0;
                            _score = 0;
                            _showResult = false;
                          });
                          _startRound();
                        },
                        icon: const Icon(Icons.replay),
                        label: const Text('Play Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B9D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
