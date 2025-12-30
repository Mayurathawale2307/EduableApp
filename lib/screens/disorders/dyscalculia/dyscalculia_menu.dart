import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class DyscalculiaMenu extends StatefulWidget {
  const DyscalculiaMenu({super.key});

  @override
  State<DyscalculiaMenu> createState() => _DyscalculiaMenuState();
}

class _DyscalculiaMenuState extends State<DyscalculiaMenu> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dyscalculia Learning Menu'),
        backgroundColor: const Color(0xFFFFB84D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => NavigationHelper.navigateToHome(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFB84D).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: _selectedTab == 0
                  ? _buildQuestionsTab()
                  : _selectedTab == 1
                      ? _buildActivitiesTab()
                      : _selectedTab == 2
                          ? _buildLearningStudiesTab()
                          : _buildResourcesTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Questions',
              icon: Icons.quiz,
              isActive: _selectedTab == 0,
              color: const Color(0xFFFFB84D),
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Activities',
              icon: Icons.games,
              isActive: _selectedTab == 1,
              color: const Color(0xFFFFB84D),
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Studies',
              icon: Icons.school,
              isActive: _selectedTab == 2,
              color: const Color(0xFFFFB84D),
              onTap: () => setState(() => _selectedTab = 2),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Resources',
              icon: Icons.library_books,
              isActive: _selectedTab == 3,
              color: const Color(0xFFFFB84D),
              onTap: () => setState(() => _selectedTab = 3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab() {
    final questions = [
      {
        'question': 'Does your child struggle with basic math operations?',
        'category': 'Basic Math',
      },
      {
        'question': 'Does your child have difficulty understanding number concepts?',
        'category': 'Number Sense',
      },
      {
        'question': 'Does your child mix up number order?',
        'category': 'Sequencing',
      },
      {
        'question': 'Does your child have trouble telling time?',
        'category': 'Time Concepts',
      },
      {
        'question': 'Does your child struggle with counting?',
        'category': 'Counting',
      },
      {
        'question': 'Does your child have difficulty with money calculations?',
        'category': 'Money',
      },
      {
        'question': 'Does your child avoid math-related activities?',
        'category': 'Behavior',
      },
      {
        'question': 'Does your child have trouble understanding measurements?',
        'category': 'Measurement',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFB84D),
                    const Color(0xFFFFB84D).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.calculate, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Dyscalculia Assessment Questions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Identify math learning challenges',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...questions.map((q) => _QuestionCard(
                question: q['question'] as String,
                category: q['category'] as String,
                color: const Color(0xFFFFB84D),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/dyscalculia/support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB84D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward),
                SizedBox(width: 8),
                Text('Get Support & Resources'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    final activities = [
      {
        'title': 'Number Games',
        'icon': Icons.casino,
        'description': 'Fun games to build number sense',
        'color': Colors.orange,
      },
      {
        'title': 'Visual Math',
        'icon': Icons.visibility,
        'description': 'Visual aids for math concepts',
        'color': Colors.blue,
      },
      {
        'title': 'Counting Practice',
        'icon': Icons.format_list_numbered,
        'description': 'Interactive counting exercises',
        'color': Colors.green,
      },
      {
        'title': 'Math Stories',
        'icon': Icons.menu_book,
        'description': 'Story-based math learning',
        'color': Colors.purple,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Activities',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F2E),
            ),
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) => _ActivityCard(
                title: activity['title'] as String,
                icon: activity['icon'] as IconData,
                description: activity['description'] as String,
                color: activity['color'] as Color,
              )),
        ],
      ),
    );
  }

  Widget _buildLearningStudiesTab() {
    final studies = [
      {
        'title': 'Number Sense & Counting',
        'description': 'Build fundamental understanding of numbers',
        'lessons': [
          'Number recognition and identification',
          'Counting forward and backward',
          'Number sequencing',
          'Understanding number relationships',
        ],
        'icon': Icons.numbers,
        'color': Colors.orange,
      },
      {
        'title': 'Basic Operations',
        'description': 'Master addition, subtraction, multiplication, division',
        'lessons': [
          'Visual addition strategies',
          'Subtraction with manipulatives',
          'Multiplication concepts',
          'Division basics',
        ],
        'icon': Icons.calculate,
        'color': Colors.blue,
      },
      {
        'title': 'Time & Money',
        'description': 'Learn to tell time and handle money',
        'lessons': [
          'Reading analog and digital clocks',
          'Understanding time concepts',
          'Counting money and making change',
          'Money management basics',
        ],
        'icon': Icons.access_time,
        'color': Colors.green,
      },
      {
        'title': 'Measurement & Geometry',
        'description': 'Understand measurements and shapes',
        'lessons': [
          'Length, weight, and volume',
          'Basic geometric shapes',
          'Spatial reasoning',
          'Measurement tools',
        ],
        'icon': Icons.straighten,
        'color': Colors.purple,
      },
      {
        'title': 'Problem Solving',
        'description': 'Develop math problem-solving skills',
        'lessons': [
          'Word problem strategies',
          'Breaking down complex problems',
          'Visual problem representation',
          'Step-by-step problem solving',
        ],
        'icon': Icons.lightbulb,
        'color': Colors.teal,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFB84D),
                    const Color(0xFFFFB84D).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.school, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Learning Studies',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Structured learning content to help you grow',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...studies.map((study) => _StudyCard(
                title: study['title'] as String,
                description: study['description'] as String,
                lessons: study['lessons'] as List<String>,
                icon: study['icon'] as IconData,
                color: study['color'] as Color,
              )),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Helpful Resources',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F2E),
            ),
          ),
          const SizedBox(height: 16),
          _ResourceCard(
            title: 'Understanding Dyscalculia',
            icon: Icons.info,
            color: const Color(0xFFFFB84D),
            onTap: () => context.go('/dyscalculia/signs'),
          ),
          _ResourceCard(
            title: 'Support & Guidance',
            icon: Icons.support_agent,
            color: const Color(0xFFFFB84D),
            onTap: () => context.go('/dyscalculia/support'),
          ),
          _ResourceCard(
            title: 'Learning Materials',
            icon: Icons.menu_book,
            color: const Color(0xFFFFB84D),
            onTap: () => context.go('/dyscalculia/resources'),
          ),
        ],
      ),
    );
  }
}

class _StudyCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> lessons;
  final IconData icon;
  final Color color;

  const _StudyCard({
    required this.title,
    required this.description,
    required this.lessons,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F1F2E),
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Learning Topics:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F2E),
                  ),
                ),
                const SizedBox(height: 12),
                ...lessons.map((lesson) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lesson,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1F1F2E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Start Learning'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final String category;
  final Color color;

  const _QuestionCard({
    required this.question,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F1F2E),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                    child: const Text('Yes'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                    child: const Text('Sometimes'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('No'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final Color color;

  const _ActivityCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F1F2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ResourceCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F1F2E),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap,
      ),
    );
  }
}
