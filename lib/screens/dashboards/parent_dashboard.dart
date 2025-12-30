import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/navbar.dart';
import '../../utils/navigation_helper.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedTab = 0;

  // Mock data for student growth - in real app, this would come from API
  final Map<String, Map<String, dynamic>> studentProgress = {
    'Dyslexia': {
      'progress': 75,
      'lessonsCompleted': 12,
      'improvement': '+15%',
      'color': const Color(0xFFFF6B9D),
    },
    'Dysgraphia': {
      'progress': 68,
      'lessonsCompleted': 10,
      'improvement': '+12%',
      'color': const Color(0xFFA78BFA),
    },
    'Dyscalculia': {
      'progress': 82,
      'lessonsCompleted': 15,
      'improvement': '+18%',
      'color': const Color(0xFFFFB84D),
    },
    'ADHD': {
      'progress': 70,
      'lessonsCompleted': 11,
      'improvement': '+14%',
      'color': const Color(0xFF34D399),
    },
    'Autism (ASD)': {
      'progress': 65,
      'lessonsCompleted': 9,
      'improvement': '+10%',
      'color': const Color(0xFF60A5FA),
    },
  };

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
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
            child: _selectedTab == 0
                ? _buildOverviewTab(appProvider)
                : _selectedTab == 1
                    ? _buildGrowthTab()
                    : _buildStudentsTab(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => setState(() => _selectedTab = index),
        selectedItemColor: const Color(0xFF7E8BFF),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Growth',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Students',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AppProvider appProvider) {
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
                    const Color(0xFF7E8BFF),
                    const Color(0xFF7E8BFF).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.family_restroom, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome, ${appProvider.userName}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track your child\'s learning progress',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Student Progress by Disability Type',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F2E),
            ),
          ),
          const SizedBox(height: 16),
          ...studentProgress.entries.map((entry) => _ProgressCard(
                disability: entry.key,
                progress: entry.value['progress'] as int,
                lessonsCompleted: entry.value['lessonsCompleted'] as int,
                improvement: entry.value['improvement'] as String,
                color: entry.value['color'] as Color,
              )),
        ],
      ),
    );
  }

  Widget _buildGrowthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Tracking',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F2E),
            ),
          ),
          const SizedBox(height: 16),
          ...studentProgress.entries.map((entry) => _GrowthCard(
                disability: entry.key,
                progress: entry.value['progress'] as int,
                improvement: entry.value['improvement'] as String,
                color: entry.value['color'] as Color,
              )),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    // Mock student data
    final students = [
      {'name': 'Emma Johnson', 'disability': 'Dyslexia', 'progress': 75},
      {'name': 'Liam Smith', 'disability': 'ADHD', 'progress': 70},
      {'name': 'Sophia Brown', 'disability': 'Autism (ASD)', 'progress': 65},
      {'name': 'Noah Davis', 'disability': 'Dyscalculia', 'progress': 82},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Students',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F2E),
            ),
          ),
          const SizedBox(height: 16),
          ...students.map((student) => _StudentCard(
                name: student['name'] as String,
                disability: student['disability'] as String,
                progress: student['progress'] as int,
              )),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String disability;
  final int progress;
  final int lessonsCompleted;
  final String improvement;
  final Color color;

  const _ProgressCard({
    required this.disability,
    required this.progress,
    required this.lessonsCompleted,
    required this.improvement,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getDisabilityIcon(disability),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disability,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F2E),
                        ),
                      ),
                      Text(
                        '$lessonsCompleted lessons completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    improvement,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDisabilityIcon(String disability) {
    switch (disability) {
      case 'Dyslexia':
        return Icons.menu_book;
      case 'Dysgraphia':
        return Icons.edit;
      case 'Dyscalculia':
        return Icons.calculate;
      case 'ADHD':
        return Icons.bolt;
      case 'Autism (ASD)':
        return Icons.psychology;
      default:
        return Icons.help;
    }
  }
}

class _GrowthCard extends StatelessWidget {
  final String disability;
  final int progress;
  final String improvement;
  final Color color;

  const _GrowthCard({
    required this.disability,
    required this.progress,
    required this.improvement,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  disability,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F2E),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        improvement,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Mock growth chart visualization
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBar(40, color),
                  _buildBar(55, color),
                  _buildBar(60, color),
                  _buildBar(progress, color),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Current', '$progress%', color),
                _buildStat('Target', '90%', Colors.grey),
                _buildStat('Growth', improvement, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(int height, Color color) {
    return Container(
      width: 30,
      height: height.toDouble(),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final String disability;
  final int progress;

  const _StudentCard({
    required this.name,
    required this.disability,
    required this.progress,
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
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7E8BFF).withOpacity(0.1),
          child: Text(
            name[0],
            style: const TextStyle(
              color: Color(0xFF7E8BFF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F1F2E),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(disability),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7E8BFF)),
              minHeight: 4,
            ),
          ],
        ),
        trailing: Text(
          '$progress%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF7E8BFF),
          ),
        ),
      ),
    );
  }
}
