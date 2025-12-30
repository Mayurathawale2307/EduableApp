import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/navigation_helper.dart';

class DisorderSelectScreen extends StatelessWidget {
  const DisorderSelectScreen({super.key});

  static const List<Map<String, dynamic>> disorders = [
    {
      'title': 'Dyslexia',
      'emoji': '📖',
      'desc': 'Reading & word understanding',
      'color': Color(0xFFFF6B9D),
      'bgColor': Color(0xFFFFE5EC),
      'route': '/dyslexia',
    },
    {
      'title': 'Dysgraphia',
      'emoji': '✍️',
      'desc': 'Writing & handwriting skills',
      'color': Color(0xFFA78BFA),
      'bgColor': Color(0xFFF3E8FF),
      'route': '/dysgraphia',
    },
    {
      'title': 'Dyscalculia',
      'emoji': '🔢',
      'desc': 'Numbers & math learning',
      'color': Color(0xFFFFB84D),
      'bgColor': Color(0xFFFFF4E6),
      'route': '/dyscalculia',
    },
    {
      'title': 'ADHD',
      'emoji': '⚡',
      'desc': 'Focus & attention support',
      'color': Color(0xFF34D399),
      'bgColor': Color(0xFFE6FFFA),
      'route': '/adhd',
    },
    {
      'title': 'Autism (ASD)',
      'emoji': '🧩',
      'desc': 'Social & sensory learning',
      'color': Color(0xFF60A5FA),
      'bgColor': Color(0xFFEFF6FF),
      'route': '/autism',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFEFF6FF),
              const Color(0xFFF3E8FF),
              const Color(0xFFFFE5EC),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Choose Your Learning Path',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F2E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Every child learns differently. Select the area where you\'d like personalized support.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F1F2E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: disorders.length,
                  itemBuilder: (context, index) {
                    final disorder = disorders[index];
                    return _DisorderCard(
                      title: disorder['title'] as String,
                      emoji: disorder['emoji'] as String,
                      desc: disorder['desc'] as String,
                      color: disorder['color'] as Color,
                      bgColor: disorder['bgColor'] as Color,
                      route: disorder['route'] as String,
                    );
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/assessment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E8BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Take Assessment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => NavigationHelper.navigateToHome(context),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisorderCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String desc;
  final Color color;
  final Color bgColor;
  final String route;

  const _DisorderCard({
    required this.title,
    required this.emoji,
    required this.desc,
    required this.color,
    required this.bgColor,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F2E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

