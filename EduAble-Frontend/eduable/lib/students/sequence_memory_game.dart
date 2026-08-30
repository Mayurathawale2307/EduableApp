import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SequenceMemoryGame extends StatefulWidget {
  const SequenceMemoryGame({super.key});

  @override
  State<SequenceMemoryGame> createState() => _SequenceMemoryGameState();
}

class _SequenceMemoryGameState extends State<SequenceMemoryGame> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentLevel = 1;
  int _currentStage = 0; // 0: listening, 1: arranging
  List<String> _sentences = [];
  List<String> _shuffledSentences = [];
  List<String> _userOrder = [];
  bool _isPlaying = false;
  int _score = 0;
  int _starsEarned = 0;
  bool _showResult = false;
  bool _levelComplete = false;

  // Level configurations
  final Map<int, LevelConfig> _levelConfigs = {
    1: LevelConfig(sentences: 3, speed: 0.8, name: 'Beginner'),
    2: LevelConfig(sentences: 3, speed: 0.9, name: 'Easy'),
    3: LevelConfig(sentences: 4, speed: 0.9, name: 'Moderate'),
    4: LevelConfig(sentences: 4, speed: 1.0, name: 'Medium'),
    5: LevelConfig(sentences: 5, speed: 1.0, name: 'Challenging'),
    6: LevelConfig(sentences: 5, speed: 1.1, name: 'Hard'),
    7: LevelConfig(sentences: 6, speed: 1.1, name: 'Very Hard'),
    8: LevelConfig(sentences: 6, speed: 1.2, name: 'Expert'),
    9: LevelConfig(sentences: 7, speed: 1.2, name: 'Master'),
    10: LevelConfig(sentences: 7, speed: 1.3, name: 'Legend'),
  };

  // Sentence sets for different levels
  final List<List<String>> _sentenceSets = [
    [
      'The sun rises in the east every morning',
      'Birds sing beautifully at dawn',
      'People start their daily routines',
    ],
    [
      'Reading books expands your knowledge',
      'Practice makes perfect in learning',
      'Never give up on your dreams',
    ],
    [
      'The ocean waves crash on the shore',
      'Seagulls fly across the blue sky',
      'Children build sandcastles on the beach',
      'The sunset paints the sky orange',
    ],
    [
      'Science helps us understand the world',
      'Mathematics is the language of logic',
      'History teaches us valuable lessons',
      'Art expresses human creativity',
    ],
    [
      'Plants need sunlight to grow',
      'Water is essential for all life',
      'Exercise keeps your body healthy',
      'Sleep helps your mind recover',
      'Good food fuels your energy',
    ],
    [
      'The library is a place of learning',
      'Students gather knowledge from books',
      'Teachers guide us on our journey',
      'Education opens doors to opportunities',
      'Curiosity drives scientific discovery',
    ],
    [
      'Technology changes how we live',
      'Computers process information quickly',
      'Internet connects people worldwide',
      'Innovation solves complex problems',
      'Digital skills are important today',
      'Future depends on smart decisions',
    ],
    [
      'Music touches the human soul',
      'Rhythm and melody create harmony',
      'Instruments produce beautiful sounds',
      'Singing brings joy to many people',
      'Practice improves musical performance',
      'Concerts unite audiences together',
    ],
    [
      'Nature provides us with resources',
      'Forests are home to wildlife',
      'Mountains touch the clouds above',
      'Rivers flow towards the oceans',
      'Seasons change throughout the year',
      'Weather affects our daily activities',
      'Conservation protects our planet',
    ],
    [
      'Space exploration fascinates humanity',
      'Stars twinkle in the night sky',
      'Planets orbit around the sun',
      'Astronauts travel beyond Earth',
      'Galaxies contain billions of stars',
      'The universe is vast and mysterious',
      'Science reveals cosmic secrets',
    ],
  ];

  @override
  void initState() {
    super.initState();
    _initTTS();
    _loadLevel(_currentLevel);
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _loadLevel(int level) {
    setState(() {
      _currentLevel = level;
      _sentences = List.from(_sentenceSets[level - 1]);
      _shuffledSentences = List.from(_sentences)..shuffle();
      _userOrder = [];
      _currentStage = 0;
      _showResult = false;
      _levelComplete = false;
    });
  }

  Future<void> _playSentences() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    var config = _levelConfigs[_currentLevel]!;

    for (int i = 0; i < _sentences.length; i++) {
      if (!mounted) return;
      setState(() => _currentStage = i);
      await _flutterTts.speak(_sentences[i]);
      await Future.delayed(Duration(milliseconds: (1500 / config.speed).round()));
    }

    if (mounted) {
      setState(() {
        _currentStage = _sentences.length;
        _isPlaying = false;
      });
      _showShuffledSentences();
    }
  }

  void _showShuffledSentences() {
    setState(() {
      _currentStage = 100; // Arranging phase
    });
  }

  void _selectSentence(int index) {
    if (_userOrder.contains(_shuffledSentences[index])) return;

    setState(() {
      _userOrder.add(_shuffledSentences[index]);
    });

    // Play sound effect
    _playClickSound();

    // Check if all sentences selected
    if (_userOrder.length == _sentences.length) {
      _checkAnswer();
    }
  }

  void _removeLastSentence() {
    if (_userOrder.isNotEmpty) {
      setState(() {
        _userOrder.removeLast();
      });
      _playClickSound();
    }
  }

  void _clearSelection() {
    setState(() {
      _userOrder.clear();
    });
    _playClickSound();
  }

  Future<void> _playClickSound() async {
    await _flutterTts.setVolume(0.3);
    await _flutterTts.speak('tap');
    await Future.delayed(const Duration(milliseconds: 200));
    await _flutterTts.setVolume(1.0);
  }

  void _checkAnswer() {
    int correct = 0;
    for (int i = 0; i < _sentences.length; i++) {
      if (_userOrder[i] == _sentences[i]) {
        correct++;
      }
    }

    if (correct == _sentences.length) {
      _starsEarned = 3;
      _score += 100 * _currentLevel;
      _levelComplete = true;
    } else if (correct >= _sentences.length * 0.7) {
      _starsEarned = 2;
      _score += 50 * _currentLevel;
    } else if (correct >= _sentences.length * 0.4) {
      _starsEarned = 1;
      _score += 25 * _currentLevel;
    } else {
      _starsEarned = 0;
    }

    setState(() {
      _showResult = true;
    });
  }

  void _nextLevel() {
    if (_currentLevel < 10 && _levelComplete) {
      _loadLevel(_currentLevel + 1);
      _playSentences();
    } else {
      _loadLevel(_currentLevel);
    }
  }

  void _retryLevel() {
    _loadLevel(_currentLevel);
    _playSentences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Sequence Memory Game',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _showResult
          ? _buildResultScreen()
          : Column(
              children: [
                _buildLevelProgress(),
                _buildGameArea(),
              ],
            ),
    );
  }

  Widget _buildLevelProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $_currentLevel',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7),
                ),
              ),
              Text(
                _levelConfigs[_currentLevel]!.name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(10, (index) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 8,
                  decoration: BoxDecoration(
                    color: index < _currentLevel
                        ? const Color(0xFF673AB7)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    if (_currentStage < _sentences.length) {
      return _buildListeningPhase();
    } else {
      return _buildArrangingPhase();
    }
  }

  Widget _buildListeningPhase() {
    var config = _levelConfigs[_currentLevel]!;

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF673AB7).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _isPlaying ? Icons.volume_up : Icons.headphones,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isPlaying
                        ? 'Listening to sentence ${_currentStage + 1} of ${_sentences.length}'
                        : 'Tap to start listening',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${config.sentences} sentences • Speed: ${config.speed}x',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!_isPlaying)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _playSentences,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Play Sentences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            if (_isPlaying)
              Column(
                children: List.generate(_sentences.length, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: index == _currentStage
                          ? const Color(0xFF673AB7).withOpacity(0.2)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: index == _currentStage
                            ? const Color(0xFF673AB7)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          index == _currentStage
                              ? Icons.volume_up
                              : index < _currentStage
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                          color: index == _currentStage
                              ? const Color(0xFF673AB7)
                              : index < _currentStage
                                  ? Colors.green
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sentence ${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: index == _currentStage
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrangingPhase() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Order:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _userOrder.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Tap sentences below in the correct order',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : Column(
                      children: _userOrder.asMap().entries.map((entry) {
                        return _buildOrderedSentence(entry.key, entry.value);
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Available Sentences:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: _shuffledSentences.asMap().entries.map((entry) {
                return _buildSelectableSentence(entry.key, entry.value);
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _userOrder.isEmpty ? null : _removeLastSentence,
                    icon: const Icon(Icons.undo),
                    label: const Text('Undo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF673AB7),
                      side: const BorderSide(color: Color(0xFF673AB7)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _userOrder.isEmpty ? null : _clearSelection,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderedSentence(int index, String sentence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF673AB7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF673AB7).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF673AB7),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sentence,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableSentence(int index, String sentence) {
    bool isSelected = _userOrder.contains(sentence);

    return GestureDetector(
      onTap: isSelected ? null : () => _selectSentence(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.grey : const Color(0xFF673AB7),
            width: isSelected ? 1 : 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              color: isSelected ? Colors.grey : const Color(0xFF673AB7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sentence,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.grey : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    int correct = 0;
    for (int i = 0; i < _sentences.length; i++) {
      if (_userOrder[i] == _sentences[i]) {
        correct++;
      }
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF673AB7).withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _levelComplete ? 'Excellent!' : 'Good Try!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Icon(
                        index < _starsEarned ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 48,
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$correct/${_sentences.length} correct',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Score: +${_levelComplete ? 100 * _currentLevel : correct >= _sentences.length * 0.7 ? 50 * _currentLevel : 25 * _currentLevel}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_levelComplete && _currentLevel < 10)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _nextLevel,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'Next Level',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _retryLevel,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Retry Level',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF673AB7),
                  side: const BorderSide(color: Color(0xFF673AB7), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}

class LevelConfig {
  final int sentences;
  final double speed;
  final String name;

  LevelConfig({
    required this.sentences,
    required this.speed,
    required this.name,
  });
}
