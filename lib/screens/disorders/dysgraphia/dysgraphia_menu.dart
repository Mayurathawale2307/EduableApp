import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/navigation_helper.dart';

class DysgraphiaMenu extends StatefulWidget {
  const DysgraphiaMenu({super.key});

  @override
  State<DysgraphiaMenu> createState() => _DysgraphiaMenuState();
}

class _DysgraphiaMenuState extends State<DysgraphiaMenu> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dysgraphia Learning Menu'),
        backgroundColor: const Color(0xFFA78BFA),
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
              const Color(0xFFA78BFA).withOpacity(0.1),
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
              color: const Color(0xFFA78BFA),
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Activities',
              icon: Icons.games,
              isActive: _selectedTab == 1,
              color: const Color(0xFFA78BFA),
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Studies',
              icon: Icons.school,
              isActive: _selectedTab == 2,
              color: const Color(0xFFA78BFA),
              onTap: () => setState(() => _selectedTab = 2),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Resources',
              icon: Icons.library_books,
              isActive: _selectedTab == 3,
              color: const Color(0xFFA78BFA),
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
        'question': 'Is your child\'s handwriting messy or hard to read?',
        'category': 'Handwriting',
      },
      {
        'question': 'Does your child struggle to write neatly?',
        'category': 'Handwriting',
      },
      {
        'question': 'Does your child get tired while writing?',
        'category': 'Physical',
      },
      {
        'question': 'Does your child have difficulty spacing words?',
        'category': 'Organization',
      },
      {
        'question': 'Does your child mix uppercase and lowercase letters?',
        'category': 'Consistency',
      },
      {
        'question': 'Does your child avoid writing tasks?',
        'category': 'Behavior',
      },
      {
        'question': 'Does your child have trouble forming letters correctly?',
        'category': 'Motor Skills',
      },
      {
        'question': 'Does your child write slowly compared to peers?',
        'category': 'Speed',
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
                    const Color(0xFFA78BFA),
                    const Color(0xFFA78BFA).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.edit, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Dysgraphia Assessment Questions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Identify writing and handwriting challenges',
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
                color: const Color(0xFFA78BFA),
              )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/dysgraphia/support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA78BFA),
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
        'title': 'Handwriting Practice',
        'icon': Icons.draw,
        'description': 'Guided exercises to improve letter formation',
        'color': Colors.purple,
      },
      {
        'title': 'Fine Motor Skills',
        'icon': Icons.handyman,
        'description': 'Activities to strengthen hand muscles',
        'color': Colors.blue,
      },
      {
        'title': 'Typing Skills',
        'icon': Icons.keyboard,
        'description': 'Learn keyboarding as an alternative',
        'color': Colors.green,
      },
      {
        'title': 'Writing Organization',
        'icon': Icons.format_align_left,
        'description': 'Tools to structure written work',
        'color': Colors.orange,
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
        'title': 'Handwriting Fundamentals',
        'description': 'Master the basics of letter formation and writing',
        'lessons': [
          'Proper pencil grip techniques',
          'Letter formation patterns',
          'Line spacing and alignment',
          'Consistent letter sizing',
        ],
        'icon': Icons.edit,
        'color': Colors.purple,
      },
      {
        'title': 'Fine Motor Development',
        'description': 'Strengthen hand muscles and coordination',
        'lessons': [
          'Hand strengthening exercises',
          'Finger dexterity activities',
          'Hand-eye coordination',
          'Bilateral coordination skills',
        ],
        'icon': Icons.handyman,
        'color': Colors.blue,
      },
      {
        'title': 'Writing Organization',
        'description': 'Learn to structure and organize written work',
        'lessons': [
          'Paragraph structure',
          'Sentence formation',
          'Spacing and formatting',
          'Writing flow and coherence',
        ],
        'icon': Icons.format_align_left,
        'color': Colors.green,
      },
      {
        'title': 'Alternative Writing Methods',
        'description': 'Explore typing and other writing alternatives',
        'lessons': [
          'Touch typing skills',
          'Voice-to-text technology',
          'Digital writing tools',
          'Adaptive writing aids',
        ],
        'icon': Icons.keyboard,
        'color': Colors.orange,
      },
      {
        'title': 'Writing Speed & Endurance',
        'description': 'Build writing stamina and speed',
        'lessons': [
          'Gradual writing practice',
          'Building writing endurance',
          'Speed writing techniques',
          'Reducing writing fatigue',
        ],
        'icon': Icons.speed,
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
                    const Color(0xFFA78BFA),
                    const Color(0xFFA78BFA).withOpacity(0.7),
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
            title: 'Understanding Dysgraphia',
            icon: Icons.info,
            color: const Color(0xFFA78BFA),
            onTap: () => context.go('/dysgraphia/signs'),
          ),
          _ResourceCard(
            title: 'Support & Guidance',
            icon: Icons.support_agent,
            color: const Color(0xFFA78BFA),
            onTap: () => context.go('/dysgraphia/support'),
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
