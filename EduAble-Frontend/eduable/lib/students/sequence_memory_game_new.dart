import 'package:flutter/material.dart';
import 'sequence_game_play.dart';

class SequenceMemoryGameNew extends StatefulWidget {
  const SequenceMemoryGameNew({super.key});

  @override
  State<SequenceMemoryGameNew> createState() => _SequenceMemoryGameNewState();
}

class _SequenceMemoryGameNewState extends State<SequenceMemoryGameNew> {
  int _currentLevel = 1;
  int _score = 0;
  final Map<int, int> _levelStars = {}; // level -> stars earned

  final List<LevelTheme> _levelThemes = [
    LevelTheme(
      level: 1,
      name: 'First Steps',
      gradient: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
      icon: Icons.language,
      background: '🌱',
      sentences: 3,
      description: 'Start your journey',
    ),
    LevelTheme(
      level: 2,
      name: 'Growing Mind',
      gradient: [Color(0xFF8BC34A), Color(0xFF9CCC65)],
      icon: Icons.psychology,
      background: '🌿',
      sentences: 3,
      description: 'Building momentum',
    ),
    LevelTheme(
      level: 3,
      name: 'Memory Lane',
      gradient: [Color(0xFFCDDC39), Color(0xFFD4E157)],
      icon: Icons.auto_awesome,
      background: '🌳',
      sentences: 4,
      description: 'Path gets interesting',
    ),
    LevelTheme(
      level: 4,
      name: 'Brain Boost',
      gradient: [Color(0xFFFFEB3B), Color(0xFFFFF176)],
      icon: Icons.lightbulb,
      background: '🌻',
      sentences: 4,
      description: 'Power up your mind',
    ),
    LevelTheme(
      level: 5,
      name: 'Focus Zone',
      gradient: [Color(0xFFFF9800), Color(0xFFFFA726)],
      icon: Icons.flag,
      background: '🎯',
      sentences: 5,
      description: 'Halfway there!',
    ),
    LevelTheme(
      level: 6,
      name: 'Memory Master',
      gradient: [Color(0xFFFF5722), Color(0xFFFF7043)],
      icon: Icons.workspace_premium,
      background: '🔥',
      sentences: 5,
      description: 'Getting serious',
    ),
    LevelTheme(
      level: 7,
      name: 'Expert Territory',
      gradient: [Color(0xFFE91E63), Color(0xFFEC407A)],
      icon: Icons.military_tech,
      background: '⚡',
      sentences: 6,
      description: 'Elite level',
    ),
    LevelTheme(
      level: 8,
      name: 'Champion Path',
      gradient: [Color(0xFF9C27B0), Color(0xFFAB47BC)],
      icon: Icons.emoji_events,
      background: '👑',
      sentences: 6,
      description: 'Almost there',
    ),
    LevelTheme(
      level: 9,
      name: 'Legend Mode',
      gradient: [Color(0xFF673AB7), Color(0xFF7E57C2)],
      icon: Icons.diamond,
      background: '💎',
      sentences: 7,
      description: 'Legendary status',
    ),
    LevelTheme(
      level: 10,
      name: 'Ultimate Mind',
      gradient: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
      icon: Icons.auto_awesome_mosaic,
      background: '🌟',
      sentences: 7,
      description: 'Final challenge',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Sequence Memory',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF16213E),
            ),
            child: Column(
              children: [
                const Text(
                  'Train Your Memory',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentLevel - 1) / 10,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4CAF50),
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  'Level $_currentLevel of 10',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Level Map (Candy Crush style)
          Expanded(
            child: _buildLevelMap(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelMap() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Zigzag path layout like Candy Crush
          for (int i = 0; i < _levelThemes.length; i++)
            _buildLevelNode(_levelThemes[i], i),
        ],
      ),
    );
  }

  Widget _buildLevelNode(LevelTheme theme, int index) {
    bool isUnlocked = theme.level <= _currentLevel;
    bool isCompleted = _levelStars.containsKey(theme.level);
    int stars = _levelStars[theme.level] ?? 0;

    return Row(
      mainAxisAlignment: index % 2 == 0
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        if (index % 2 == 0) const SizedBox(width: 40),
        GestureDetector(
          onTap: isUnlocked ? () => _startLevel(theme.level) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width * 0.65,
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(
                      colors: [
                        theme.gradient[0],
                        theme.gradient[1],
                      ],
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade700, Colors.grey.shade600],
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isUnlocked
                      ? theme.gradient[0].withOpacity(0.5)
                      : Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Level number and emoji
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      theme.background,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${theme.level}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  theme.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.white : Colors.grey.shade400,
                  ),
                ),
                Text(
                  theme.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),

                // Stars
                if (isCompleted)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      );
                    }),
                  ),

                // Sentence count badge
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${theme.sentences} sentences',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Lock icon for locked levels
                if (!isUnlocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(Icons.lock, color: Colors.grey, size: 24),
                  ),
              ],
            ),
          ),
        ),
        if (index % 2 == 1) const SizedBox(width: 40),

        // Path connector
        if (index < _levelThemes.length - 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Icon(
              Icons.remove,
              color: isUnlocked && index + 1 < _currentLevel
                  ? Colors.green
                  : Colors.grey.shade700,
              size: 40,
            ),
          ),
      ],
    );
  }

  void _startLevel(int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SequenceGamePlay(
          level: level,
          levelTheme: _levelThemes[level - 1],
          onComplete: (stars, score) {
            setState(() {
              _levelStars[level] = stars;
              _score += score;
              if (stars >= 1 && level == _currentLevel && level < 10) {
                _currentLevel = level + 1;
              }
            });
          },
        ),
      ),
    );
  }
}

class LevelTheme {
  final int level;
  final String name;
  final List<Color> gradient;
  final IconData icon;
  final String background;
  final int sentences;
  final String description;

  LevelTheme({
    required this.level,
    required this.name,
    required this.gradient,
    required this.icon,
    required this.background,
    required this.sentences,
    required this.description,
  });
}
