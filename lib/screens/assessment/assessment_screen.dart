import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/navigation_helper.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _currentQuestion = 0;
  final Map<int, int> _answers = {};
  Map<String, int>? _result;

  final List<Map<String, dynamic>> questions = const [
    {
      'id': 1,
      'question': 'Does the child mix up letters like b-d or p-q when reading or writing?',
      'disability': 'Dyslexia',
      'category': 'Reading & Writing',
    },
    {
      'id': 2,
      'question': 'Does the child read very slowly or guess words?',
      'disability': 'Dyslexia',
      'category': 'Reading & Writing',
    },
    {
      'id': 3,
      'question': 'Does the child skip words while reading?',
      'disability': 'Dyslexia',
      'category': 'Reading & Writing',
    },
    {
      'id': 4,
      'question': 'Is the child\'s handwriting messy or hard to read?',
      'disability': 'Dysgraphia',
      'category': 'Writing Skills',
    },
    {
      'id': 5,
      'question': 'Does the child struggle to write neatly?',
      'disability': 'Dysgraphia',
      'category': 'Writing Skills',
    },
    {
      'id': 6,
      'question': 'Does the child get tired while writing?',
      'disability': 'Dysgraphia',
      'category': 'Writing Skills',
    },
    {
      'id': 7,
      'question': 'Does the child struggle with numbers?',
      'disability': 'Dyscalculia',
      'category': 'Mathematics',
    },
    {
      'id': 8,
      'question': 'Does the child find basic math difficult?',
      'disability': 'Dyscalculia',
      'category': 'Mathematics',
    },
    {
      'id': 9,
      'question': 'Does the child mix number order?',
      'disability': 'Dyscalculia',
      'category': 'Mathematics',
    },
    {
      'id': 10,
      'question': 'Does the child get distracted easily?',
      'disability': 'ADHD',
      'category': 'Attention & Focus',
    },
    {
      'id': 11,
      'question': 'Is it hard for the child to sit still?',
      'disability': 'ADHD',
      'category': 'Attention & Focus',
    },
    {
      'id': 12,
      'question': 'Does the child leave tasks unfinished?',
      'disability': 'ADHD',
      'category': 'Attention & Focus',
    },
    {
      'id': 13,
      'question': 'Does the child avoid eye contact?',
      'disability': 'Autism (ASD)',
      'category': 'Social Interaction',
    },
    {
      'id': 14,
      'question': 'Is the child sensitive to loud sounds?',
      'disability': 'Autism (ASD)',
      'category': 'Social Interaction',
    },
    {
      'id': 15,
      'question': 'Does the child repeat actions or words?',
      'disability': 'Autism (ASD)',
      'category': 'Social Interaction',
    },
  ];

  void _handleAnswer(int value) {
    setState(() {
      _answers[questions[_currentQuestion]['id'] as int] = value;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentQuestion < questions.length - 1) {
        setState(() {
          _currentQuestion++;
        });
      }
    });
  }

  Future<void> _calculateResult() async {
    final scores = <String, int>{
      'Dyslexia': 0,
      'Dysgraphia': 0,
      'Dyscalculia': 0,
      'ADHD': 0,
      'Autism (ASD)': 0,
    };

    for (var q in questions) {
      final disability = q['disability'] as String;
      scores[disability] = (scores[disability] ?? 0) + (_answers[q['id'] as int] ?? 0);
    }

    scores.forEach((key, value) {
      scores[key] = ((value / 6) * 100).round();
    });

    setState(() {
      _result = scores;
    });

    // Find highest disability
    final highestDisability = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Save assessment
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final result = await appProvider.saveDisabilityAssessment(
      highestDisability,
      scores.map((k, v) => MapEntry(k, v)),
    );

    if (result['success'] == true) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/recommendations');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ((_currentQuestion + 1) / questions.length) * 100;
    final currentQ = questions[_currentQuestion];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFCE4E6),
              const Color(0xFFC9C4FF).withOpacity(0.3),
              const Color(0xFF7E8BFF).withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: _result == null
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.home),
                            onPressed: () => NavigationHelper.navigateToHome(context),
                          ),
                          const Spacer(),
                          Text(
                            'Question ${_currentQuestion + 1} of ${questions.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7E8BFF)),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7E8BFF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    currentQ['category'] as String,
                                    style: const TextStyle(
                                      color: Color(0xFF7E8BFF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  currentQ['question'] as String,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F1F2E),
                                  ),
                                ),
                                const Spacer(),
                                Column(
                                  children: [
                                    _AnswerButton(
                                      label: 'Yes / Often',
                                      value: 2,
                                      selected: _answers[currentQ['id'] as int] == 2,
                                      color: Colors.red,
                                      onTap: () => _handleAnswer(2),
                                    ),
                                    const SizedBox(height: 12),
                                    _AnswerButton(
                                      label: 'Sometimes',
                                      value: 1,
                                      selected: _answers[currentQ['id'] as int] == 1,
                                      color: Colors.orange,
                                      onTap: () => _handleAnswer(1),
                                    ),
                                    const SizedBox(height: 12),
                                    _AnswerButton(
                                      label: 'No / Never',
                                      value: 0,
                                      selected: _answers[currentQ['id'] as int] == 0,
                                      color: Colors.green,
                                      onTap: () => _handleAnswer(0),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: _currentQuestion > 0
                                          ? () {
                                              setState(() {
                                                _currentQuestion--;
                                              });
                                            }
                                          : null,
                                      child: const Text('Previous'),
                                    ),
                                    if (_currentQuestion == questions.length - 1)
                                      ElevatedButton(
                                        onPressed: _answers.length == questions.length
                                            ? _calculateResult
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF7E8BFF),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Show Results'),
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentQuestion++;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF7E8BFF),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Next'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _buildResults(),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            size: 64,
            color: Color(0xFF7E8BFF),
          ),
          const SizedBox(height: 16),
          const Text(
            'Assessment Complete!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F2E),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _result!.length,
              itemBuilder: (context, index) {
                final entry = _result!.entries.elementAt(index);
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${entry.value}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7E8BFF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            entry.value >= 67
                                ? Colors.red
                                : entry.value >= 34
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Text(
            'Redirecting to recommendations...',
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final int value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

