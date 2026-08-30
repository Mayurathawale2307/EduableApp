import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'sequence_memory_game_new.dart';
import '../services/ai_explanation_service.dart';

class SequenceGamePlay extends StatefulWidget {
  final int level;
  final LevelTheme levelTheme;
  final Function(int stars, int score) onComplete;

  const SequenceGamePlay({
    super.key,
    required this.level,
    required this.levelTheme,
    required this.onComplete,
  });

  @override
  State<SequenceGamePlay> createState() => _SequenceGamePlayState();
}

class _SequenceGamePlayState extends State<SequenceGamePlay> {
  final FlutterTts _flutterTts = FlutterTts();
  int _currentPhase = 0; // 0: listening, 1: arranging
  int _currentSentenceIndex = 0;
  List<String> _sentences = [];
  List<String> _shuffledSentences = [];
  List<String> _userOrder = [];
  bool _isPlaying = false;
  bool _showResult = false;
  int _starsEarned = 0;
  int _scoreEarned = 0;
  String? _aiExplanation;
  bool _isLoadingExplanation = false;

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
    _loadLevel();
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _loadLevel() {
    setState(() {
      _sentences = List.from(_sentenceSets[widget.level - 1]);
      _shuffledSentences = List.from(_sentences)..shuffle();
      _userOrder = [];
      _currentPhase = 0;
      _currentSentenceIndex = 0;
      _showResult = false;
    });
  }

  Future<void> _playCurrentSentence() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    await _flutterTts.speak(_sentences[_currentSentenceIndex]);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _playAllSentences() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    for (int i = 0; i < _sentences.length; i++) {
      if (!mounted) return;
      setState(() => _currentSentenceIndex = i);
      await _flutterTts.speak(_sentences[i]);
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    if (mounted) {
      setState(() {
        _currentPhase = 1;
        _isPlaying = false;
      });
    }
  }

  void _nextSentence() {
    if (_currentSentenceIndex < _sentences.length - 1) {
      setState(() {
        _currentSentenceIndex++;
      });
      _playCurrentSentence();
    } else {
      setState(() {
        _currentPhase = 1;
      });
    }
  }

  void _previousSentence() {
    if (_currentSentenceIndex > 0) {
      setState(() {
        _currentSentenceIndex--;
      });
      _playCurrentSentence();
    }
  }

  void _selectSentence(int index) {
    if (_userOrder.contains(_shuffledSentences[index])) return;

    setState(() {
      _userOrder.add(_shuffledSentences[index]);
    });

    if (_userOrder.length == _sentences.length) {
      _checkAnswer();
    }
  }

  void _removeLastSentence() {
    if (_userOrder.isNotEmpty) {
      setState(() {
        _userOrder.removeLast();
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _userOrder.clear();
    });
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
      _scoreEarned = 100 * widget.level;
    } else if (correct >= _sentences.length * 0.7) {
      _starsEarned = 2;
      _scoreEarned = 50 * widget.level;
    } else if (correct >= _sentences.length * 0.4) {
      _starsEarned = 1;
      _scoreEarned = 25 * widget.level;
    } else {
      _starsEarned = 0;
      _scoreEarned = 10 * widget.level;
    }

    setState(() {
      _showResult = true;
      _aiExplanation = null;
    });

    if (_starsEarned < 3) {
      _fetchAiExplanation();
    }
  }

  Future<void> _fetchAiExplanation() async {
    setState(() => _isLoadingExplanation = true);

    try {
      final explanation = await AiExplanationService.getExplanation(
        question: "Arrange these sentences in order: ${_shuffledSentences.join(', ')}",
        userAnswer: _userOrder.join(', '),
        correctAnswer: _sentences.join(', '),
        context: "This is a memory sequence game for students. The goal is to remember the order of sentences read by the app.",
      );

      if (mounted) {
        setState(() {
          _aiExplanation = explanation;
          _isLoadingExplanation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingExplanation = false);
      }
    }
  }

  void _finishLevel() {
    widget.onComplete(_starsEarned, _scoreEarned);
    Navigator.pop(context);
  }

  void _retryLevel() {
    _loadLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              widget.levelTheme.background,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              'Level ${widget.level}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: widget.levelTheme.gradient[0],
        elevation: 0,
      ),
      body: _showResult
          ? _buildResultScreen()
          : _currentPhase == 0
              ? _buildListeningPhase()
              : _buildArrangingPhase(),
    );
  }

  Widget _buildListeningPhase() {
    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentSentenceIndex + 1) / _sentences.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.levelTheme.gradient[0],
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentSentenceIndex + 1}/${_sentences.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Large sentence card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.levelTheme.gradient[0],
                        widget.levelTheme.gradient[1],
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: widget.levelTheme.gradient[0]
                            .withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 4,
                        offset: const Offset(0, 4),
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
                      const SizedBox(height: 24),
                      Text(
                        _sentences[_currentSentenceIndex],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_isPlaying)
                        const Text(
                          '🔊 Playing...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _playCurrentSentence,
                          icon: const Icon(Icons.replay),
                          label: const Text('Listen Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Navigation buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _currentSentenceIndex > 0 ? _previousSentence : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.levelTheme.gradient[0],
                          side: BorderSide(
                            color: widget.levelTheme.gradient[0],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _nextSentence,
                        icon: Icon(
                          _currentSentenceIndex < _sentences.length - 1
                              ? Icons.arrow_forward
                              : Icons.check,
                        ),
                        label: Text(
                          _currentSentenceIndex < _sentences.length - 1
                              ? 'Next'
                              : 'Start Arranging',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.levelTheme.gradient[0],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Play all button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isPlaying ? null : _playAllSentences,
                    icon: const Icon(Icons.fast_forward),
                    label: const Text('Play All Sentences'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.levelTheme.gradient[0],
                      side: BorderSide(color: widget.levelTheme.gradient[0]),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.levelTheme.gradient[0]
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: widget.levelTheme.gradient[0],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tip: Listen carefully to the order!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.levelTheme.gradient[0],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You can replay each sentence or play all at once',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrangingPhase() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: const Text(
            'Tap sentences in the correct order',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),

        // User's order
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Order:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
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
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Sentences will appear here',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Column(
                          children: _userOrder.asMap().entries.map((entry) {
                            return _buildOrderedSentence(
                                entry.key, entry.value);
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Available Sentences:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: _shuffledSentences.asMap().entries.map((entry) {
                    return _buildSelectableSentence(
                        entry.key, entry.value);
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _userOrder.isEmpty ? null : _removeLastSentence,
                        icon: const Icon(Icons.undo),
                        label: const Text('Undo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _userOrder.isEmpty ? null : _clearSelection,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderedSentence(int index, String sentence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.levelTheme.gradient[0].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.levelTheme.gradient[0].withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.levelTheme.gradient[0],
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
            child: Text(sentence, style: const TextStyle(fontSize: 14)),
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
            color: isSelected ? Colors.grey : widget.levelTheme.gradient[0],
            width: isSelected ? 1 : 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              color: isSelected ? Colors.grey : widget.levelTheme.gradient[0],
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
                gradient: LinearGradient(
                  colors: [
                    widget.levelTheme.gradient[0],
                    widget.levelTheme.gradient[1],
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.levelTheme.gradient[0]
                        .withOpacity(0.4),
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
                    _starsEarned >= 2 ? 'Excellent!' : 'Good Try!',
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
                        index < _starsEarned
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 48,
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Score: +$_scoreEarned',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  if (_isLoadingExplanation)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  if (_aiExplanation != null)
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.psychology, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(
                                'AI Tutor Tip:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _aiExplanation!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _finishLevel,
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  'Back to Levels',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.levelTheme.gradient[0],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                  foregroundColor: widget.levelTheme.gradient[0],
                  side: BorderSide(
                    color: widget.levelTheme.gradient[0],
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
