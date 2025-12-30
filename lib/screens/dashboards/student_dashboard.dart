import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/navbar.dart';
import '../../utils/navigation_helper.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final userName = appProvider.userName;
    final userDisability = appProvider.userDisability;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: const Color(0xFF7E8BFF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => NavigationHelper.navigateToHome(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              appProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Navbar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ready to learn something amazing today?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  if (userDisability != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.psychology, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Your Learning Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Identified Disability: $userDisability',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (userDisability == 'Dyslexia') {
                                  context.go('/dyslexia/age/11-14');
                                } else if (userDisability == 'Dysgraphia') {
                                  context.go('/dysgraphia/menu');
                                } else if (userDisability == 'Dyscalculia') {
                                  context.go('/dyscalculia/menu');
                                } else if (userDisability == 'ADHD') {
                                  context.go('/adhd/menu');
                                } else if (userDisability == 'Autism (ASD)') {
                                  context.go('/autism/menu');
                                }
                              },
                              child: const Text('Go to your specialized learning path'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _TabButton(
                        label: 'Lessons',
                        isActive: _activeTab == 0,
                        onTap: () => setState(() => _activeTab = 0),
                      ),
                      const SizedBox(width: 16),
                      _TabButton(
                        label: 'Achievements',
                        isActive: _activeTab == 1,
                        onTap: () => setState(() => _activeTab = 1),
                      ),
                      const SizedBox(width: 16),
                      _TabButton(
                        label: 'Activities',
                        isActive: _activeTab == 2,
                        onTap: () => setState(() => _activeTab = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_activeTab == 0) _buildLessonsTab(),
                  if (_activeTab == 1) _buildAchievementsTab(),
                  if (_activeTab == 2) _buildActivitiesTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lessons Completed',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        '12',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Badges Earned',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        '8',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Streak',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        '5 Days',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Lessons',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _LessonItem(
                  title: 'Math: Addition & Subtraction',
                  progress: 75,
                ),
                _LessonItem(
                  title: 'English: Reading Comprehension',
                  progress: 60,
                ),
                _LessonItem(
                  title: 'Science: Plants & Animals',
                  progress: 90,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Card(
                  color: index < 3 ? Colors.yellow.shade50 : Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.star, size: 48, color: Colors.amber),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ActivityItem(
              title: 'Completed Math Quiz',
              time: '2 hours ago',
            ),
            _ActivityItem(
              title: 'Started English Lesson',
              time: 'Yesterday',
            ),
            _ActivityItem(
              title: 'Earned Reading Star Badge',
              time: '2 days ago',
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF7E8BFF) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF7E8BFF) : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  final String title;
  final int progress;

  const _LessonItem({
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('$progress%'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7E8BFF)),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;

  const _ActivityItem({
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

