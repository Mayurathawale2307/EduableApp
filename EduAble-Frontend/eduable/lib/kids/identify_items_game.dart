import 'dart:math';
import 'package:flutter/material.dart';

class IdentifyItemsGame extends StatefulWidget {
  const IdentifyItemsGame({super.key});

  @override
  State<IdentifyItemsGame> createState() => _IdentifyItemsGameState();
}

class _IdentifyItemsGameState extends State<IdentifyItemsGame> {
  int _score = 0;
  String _targetItem = '';
  String _targetEmoji = '';
  List<Map<String, String>> _options = [];
  bool _showSuccess = false;
  bool _showError = false;
  String _selectedAnswer = '';

  final List<Map<String, String>> _allItems = [
    {'emoji': '🍎', 'name': 'Apple'},
    {'emoji': '🍊', 'name': 'Orange'},
    {'emoji': '🍋', 'name': 'Lemon'},
    {'emoji': '🍇', 'name': 'Grapes'},
    {'emoji': '🍓', 'name': 'Strawberry'},
    {'emoji': '🍒', 'name': 'Cherry'},
    {'emoji': '🍑', 'name': 'Peach'},
    {'emoji': '🍌', 'name': 'Banana'},
    {'emoji': '🐱', 'name': 'Cat'},
    {'emoji': '🐶', 'name': 'Dog'},
    {'emoji': '🐰', 'name': 'Rabbit'},
    {'emoji': '🐻', 'name': 'Bear'},
    {'emoji': '🐼', 'name': 'Panda'},
    {'emoji': '🐨', 'name': 'Koala'},
    {'emoji': '🐸', 'name': 'Frog'},
    {'emoji': '🦁', 'name': 'Lion'},
    {'emoji': '🚗', 'name': 'Car'},
    {'emoji': '🚕', 'name': 'Taxi'},
    {'emoji': '🚙', 'name': 'SUV'},
    {'emoji': '🚌', 'name': 'Bus'},
    {'emoji': '🚎', 'name': 'Trolley'},
    {'emoji': '🏎️', 'name': 'Race Car'},
    {'emoji': '🚓', 'name': 'Police Car'},
    {'emoji': '⚽', 'name': 'Football'},
    {'emoji': '🏀', 'name': 'Basketball'},
    {'emoji': '🏈', 'name': 'American Football'},
    {'emoji': '⚾', 'name': 'Baseball'},
    {'emoji': '🎾', 'name': 'Tennis'},
    {'emoji': '🏐', 'name': 'Volleyball'},
  ];

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
    
    // Select target item
    int targetIndex = random.nextInt(_allItems.length);
    _targetItem = _allItems[targetIndex]['name']!;
    _targetEmoji = _allItems[targetIndex]['emoji']!;

    // Select 3 wrong options
    _options = [_allItems[targetIndex]];
    while (_options.length < 4) {
      int wrongIndex = random.nextInt(_allItems.length);
      if (!_options.contains(_allItems[wrongIndex])) {
        _options.add(_allItems[wrongIndex]);
      }
    }
    _options.shuffle();

    setState(() {
      _selectedAnswer = '';
      _showSuccess = false;
      _showError = false;
    });
  }

  void _checkAnswer(String emoji, String name) {
    setState(() {
      _selectedAnswer = emoji;
      if (name == _targetItem) {
        _score += 25;
        _showSuccess = true;
        Future.delayed(const Duration(seconds: 2), () {
          _generateQuestion();
        });
      } else {
        _showError = true;
        Future.delayed(const Duration(seconds: 1), () {
          _showError = false;
          _selectedAnswer = '';
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    Color currentColor = _colors[Random().nextInt(_colors.length)];

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
                      '🎯 Identify Items',
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
                        'Find this item:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B9D),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _targetEmoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _targetItem,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: currentColor,
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
                  childAspectRatio: 1.2,
                  children: _options.map((item) {
                    bool isSelected = _selectedAnswer == item['emoji'];
                    bool isCorrect = item['name'] == _targetItem;
                    Color bgColor = Colors.white;
                    
                    if (isSelected) {
                      bgColor = isCorrect ? Colors.green : Colors.red;
                    }

                    return GestureDetector(
                      onTap: _selectedAnswer.isEmpty ? () => _checkAnswer(item['emoji']!, item['name']!) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['emoji']!,
                              style: const TextStyle(fontSize: 50),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : currentColor,
                              ),
                            ),
                          ],
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
                        'Great Job! +25 Stars!',
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
                    label: const Text('Next Question'),
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
