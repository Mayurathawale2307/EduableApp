import 'dart:math';
import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class NumbersGame extends StatefulWidget {
  const NumbersGame({super.key});

  @override
  State<NumbersGame> createState() => _NumbersGameState();
}

class _NumbersGameState extends State<NumbersGame> {
  int _score = 0;
  int _currentNumber = 0;
  int _correctAnswer = 0;
  List<int> _options = [];
  bool _showSuccess = false;
  bool _showError = false;
  int _selectedAnswer = -1;
  final TTSService _ttsService = TTSService();

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    _generateQuestion();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  final List<String> _emojiSets = [
    '🍎', '🍊', '🍋', '🍇', '🍓', '🍒', '🍑', '🍌',
    '🐱', '🐶', '🐰', '🐻', '🐼', '🐨', '🐸', '🦁',
    '⭐', '🌟', '💫', '✨', '🎈', '🎀', '🎁', '🎊',
  ];

  String _currentEmoji = '🍎';

  final List<Color> _colors = [
    const Color(0xFFFF6B9D),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFE66D),
    const Color(0xFF95E1D3),
    const Color(0xFFEA8685),
    const Color(0xFF786FA6),
  ];

  void _generateQuestion() {
    final random = Random();
    _currentNumber = random.nextInt(9) + 1; // 1-10
    _correctAnswer = _currentNumber;
    _currentEmoji = _emojiSets[random.nextInt(_emojiSets.length)];

    // Generate options
    _options = [_correctAnswer];
    while (_options.length < 4) {
      int wrongAnswer = random.nextInt(10) + 1;
      if (!_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    _options.shuffle();

    setState(() {
      _selectedAnswer = -1;
      _showSuccess = false;
      _showError = false;
    });
    
    // Speak the question
    Future.delayed(const Duration(milliseconds: 300), () {
      _ttsService.speak('How many $_currentEmoji do you see? Count them!');
    });
  }

  void _checkAnswer(int answer) {
    setState(() {
      _selectedAnswer = answer;
      if (answer == _correctAnswer) {
        _score += 15;
        _showSuccess = true;
        _ttsService.speak('Correct! There are $_correctAnswer $_currentEmoji. Great counting!');
        Future.delayed(const Duration(seconds: 2), () {
          _generateQuestion();
        });
      } else {
        _showError = true;
        _ttsService.speak('Not quite. Try counting again!');
        Future.delayed(const Duration(seconds: 1), () {
          _showError = false;
          _selectedAnswer = -1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color currentColor = _colors[_currentNumber % _colors.length];

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
                      '🔢 Numbers Game',
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
                              color: currentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Question
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
                      const Text(
                        'How many do you see?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B9D),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          _currentNumber,
                          (index) => Text(
                            _currentEmoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Answer options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: _options.map((option) {
                    bool isSelected = _selectedAnswer == option;
                    bool isCorrect = option == _correctAnswer;
                    Color buttonColor = Colors.white;
                    
                    if (isSelected) {
                      buttonColor = isCorrect ? Colors.green : Colors.red;
                    }

                    return GestureDetector(
                      onTap: _selectedAnswer == -1 ? () => _checkAnswer(option) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: buttonColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: currentColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: currentColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            option.toString(),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : currentColor,
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
                        'Correct! +15 Stars!',
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('😅 ', style: TextStyle(fontSize: 24)),
                      Text(
                        'It\'s $_correctAnswer! Try Next!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_showSuccess || _showError) const SizedBox(height: 16),
              const Spacer(),
              // New question button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generateQuestion,
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
