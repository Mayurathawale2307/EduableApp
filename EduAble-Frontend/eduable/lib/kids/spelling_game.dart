import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/ai_explanation_service.dart';

class SpellingGame extends StatefulWidget {
  const SpellingGame({super.key});

  @override
  State<SpellingGame> createState() => _SpellingGameState();
}

class _SpellingGameState extends State<SpellingGame> {
  int _currentWordIndex = 0;
  int _score = 0;
  List<String> _selectedLetters = [];
  bool _showSuccess = false;
  bool _showError = false;
  String? _aiHint;
  bool _isLoadingHint = false;
  final TTSService _ttsService = TTSService();

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    _speakCurrentWord();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  void _speakCurrentWord() {
    _ttsService.speak('Spell the word ${_currentWord['word']}');
  }

  final List<Map<String, dynamic>> _words = [
    {
      'word': 'CAT',
      'emoji': '🐱',
      'letters': ['T', 'D', 'A', 'C', 'E', 'F'], // Shuffled
    },
    {
      'word': 'DOG',
      'emoji': '🐶',
      'letters': ['G', 'H', 'O', 'D', 'I', 'J'], // Shuffled
    },
    {
      'word': 'SUN',
      'emoji': '☀️',
      'letters': ['N', 'M', 'U', 'S', 'O', 'P'], // Shuffled
    },
    {
      'word': 'BALL',
      'emoji': '⚽',
      'letters': ['L', 'C', 'A', 'B', 'L', 'D'], // Shuffled
    },
    {
      'word': 'FISH',
      'emoji': '🐟',
      'letters': ['H', 'G', 'S', 'F', 'I', 'J'], // Shuffled
    },
    {
      'word': 'TREE',
      'emoji': '🌳',
      'letters': ['E', 'S', 'R', 'T', 'E', 'U'], // Shuffled
    },
    {
      'word': 'BOOK',
      'emoji': '📚',
      'letters': ['K', 'L', 'O', 'B', 'O', 'M'], // Shuffled
    },
    {
      'word': 'STAR',
      'emoji': '⭐',
      'letters': ['R', 'Q', 'A', 'S', 'T', 'P'], // Shuffled
    },
  ];

  final List<Color> _colors = [
    const Color(0xFFFF6B9D),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFE66D),
    const Color(0xFF95E1D3),
    const Color(0xFFEA8685),
    const Color(0xFF786FA6),
  ];

  void _selectLetter(String letter) {
    if (_selectedLetters.length < _currentWord['word'].length) {
      setState(() {
        _selectedLetters.add(letter);
      });
      _checkAnswer();
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedLetters = [];
      _showSuccess = false;
      _showError = false;
      // Note: We don't clear _aiHint here so the user can see it while they try again
    });
  }

  void _checkAnswer() {
    if (_selectedLetters.length == _currentWord['word'].length) {
      String answer = _selectedLetters.join();
      if (answer == _currentWord['word']) {
        setState(() {
          _score += 20;
          _showSuccess = true;
          _aiHint = null;
        });
        _ttsService.speak('Correct! Great spelling! You earned 20 stars!');
        Future.delayed(const Duration(seconds: 2), () {
          _nextWord();
        });
      } else {
        setState(() {
          _showError = true;
          _isLoadingHint = true;
        });
        _ttsService.speak('Try again!');

        // Get AI Hint
        AiExplanationService.getExplanation(
          question: "Spell the word for ${_currentWord['emoji']}",
          userAnswer: answer,
          correctAnswer: _currentWord['word'],
          context: "This is a spelling game for kids. The word is ${_currentWord['word']}.",
        ).then((hint) {
          if (mounted) {
            setState(() {
              _aiHint = hint;
              _isLoadingHint = false;
            });
          }
        });

        Future.delayed(const Duration(seconds: 2), () {
          _clearSelection();
        });
      }
    }
  }

  void _nextWord() {
    setState(() {
      if (_currentWordIndex < _words.length - 1) {
        _currentWordIndex++;
      } else {
        _currentWordIndex = 0;
      }
      _selectedLetters = [];
      _showSuccess = false;
      _showError = false;
      _aiHint = null;
    });
    _speakCurrentWord();
  }

  Map<String, dynamic> get _currentWord => _words[_currentWordIndex];
  Color get _currentColor => _colors[_currentWordIndex % _colors.length];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9A9E),
              Color(0xFFFECFEF),
              Color(0xFFA8EDEA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      '📖 Spelling Game',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 4),
                          Text(
                            '$_score',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _currentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Word display
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentWord['emoji'],
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 10),
                      // Speaker button to hear the word
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _speakCurrentWord();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.volume_up, color: Colors.white, size: 24),
                                      const SizedBox(width: 10),
                                      Text(
                                        '🔊 Listen: ${_currentWord['word']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: _currentColor,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_currentColor, _currentColor.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: _currentColor.withOpacity(0.6),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.volume_up, color: Colors.white, size: 32),
                                  SizedBox(width: 10),
                                  Text(
                                    'TAP TO HEAR WORD',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Spell this word!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B9D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Answer slots
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _currentWord['word'].length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 50,
                      height: 60,
                      decoration: BoxDecoration(
                        color: index < _selectedLetters.length
                            ? _currentColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _currentColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          index < _selectedLetters.length
                              ? _selectedLetters[index]
                              : '?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: index < _selectedLetters.length
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Letter buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _currentWord['letters'].map<Widget>((letter) {
                    bool isSelected = _selectedLetters.contains(letter) &&
                        _selectedLetters.lastIndexOf(letter) ==
                            _selectedLetters.indexOf(letter);
                    return GestureDetector(
                      onTap: () => _selectLetter(letter),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.grey : _currentColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: _currentColor.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Success/Error messages
              if (_showSuccess)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🎉 ', style: TextStyle(fontSize: 24)),
                      Text(
                        'Correct! +20 Stars!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_showError)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('😅 ', style: TextStyle(fontSize: 24)),
                      Text(
                        'Try Again!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_showSuccess || _showError || _aiHint != null || _isLoadingHint) const SizedBox(height: 16),
              // AI Hint
              if (_isLoadingHint)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (_aiHint != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'AI Tutor Suggestion:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _aiHint!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_showSuccess || _showError || _aiHint != null) const SizedBox(height: 16),
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _clearSelection,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _nextWord,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Skip'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ECDC4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
