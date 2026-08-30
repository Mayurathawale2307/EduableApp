import 'package:flutter/material.dart';
import 'timetable_input_page.dart';

class TimetableResultPage extends StatefulWidget {
  final Map<String, dynamic> timetableData;

  const TimetableResultPage({super.key, required this.timetableData});

  @override
  State<TimetableResultPage> createState() => _TimetableResultPageState();
}

class _TimetableResultPageState extends State<TimetableResultPage> {
  List<Map<String, dynamic>> generatedTimetable = [];
  bool isGenerating = true;

  // Subject icons mapping
  final Map<String, IconData> _subjectIcons = {
    'Math': Icons.calculate,
    'Mathematics': Icons.calculate,
    'Science': Icons.science,
    'Physics': Icons.speed,
    'Chemistry': Icons.water_drop,
    'Biology': Icons.biotech,
    'English': Icons.menu_book,
    'History': Icons.history_edu,
    'Geography': Icons.public,
    'Computer': Icons.computer,
    'Programming': Icons.code,
    'Art': Icons.palette,
    'Music': Icons.music_note,
    'Physical Education': Icons.sports,
    'PE': Icons.sports,
  };

  // Subject colors
  final List<Color> _subjectColors = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF607D8B), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _generateTimetable();
  }

  void _generateTimetable() {
    setState(() {
      isGenerating = true;
    });

    // Simulate processing time
    Future.delayed(const Duration(milliseconds: 800), () {
      _processTimetable();
      setState(() {
        isGenerating = false;
      });
    });
  }

  void _processTimetable() {
    int studyHours = widget.timetableData['studyHours'];
    int daysPerWeek = widget.timetableData['daysPerWeek'];
    List<dynamic> subjects = widget.timetableData['subjects'];

    // Sort subjects by difficulty (Hard first, then Medium, then Easy)
    subjects.sort((a, b) {
      int priorityA = _getDifficultyPriority(a['difficulty']);
      int priorityB = _getDifficultyPriority(b['difficulty']);
      return priorityB.compareTo(priorityA); // Hard first
    });

    // Calculate time allocation based on difficulty
    Map<String, double> difficultyWeights = {
      'Hard': 1.5,
      'Medium': 1.0,
      'Easy': 0.7,
    };

    double totalWeight = 0;
    for (var subject in subjects) {
      totalWeight += difficultyWeights[subject['difficulty']] ?? 1.0;
    }

    // Generate timetable for each day
    generatedTimetable = [];
    for (int day = 1; day <= daysPerWeek; day++) {
      List<Map<String, dynamic>> daySchedule = [];
      double currentHour = 9.0; // Start at 9 AM

      // Allocate time slots based on subject priority
      for (var subject in subjects) {
        if (currentHour >= 9 + studyHours) break;

        double weight = difficultyWeights[subject['difficulty']] ?? 1.0;
        double allocatedTime = (weight / totalWeight) * studyHours;

        // Round to nearest 45 minutes
        int sessions = (allocatedTime * 60 / 45).round();
        if (sessions < 1) sessions = 1;

        for (int i = 0; i < sessions; i++) {
          if (currentHour >= 9 + studyHours) break;

          double endTime = currentHour + 0.75; // 45 minutes
          if (endTime > 9 + studyHours) {
            endTime = (9 + studyHours).toDouble();
          }

          daySchedule.add({
            'type': 'subject',
            'subject': subject['name'],
            'difficulty': subject['difficulty'],
            'startTime': currentHour,
            'endTime': endTime,
            'color': _getSubjectColor(subject['name']),
          });

          currentHour = endTime;

          // Add 10-minute break if not the last session
          if (currentHour < 9 + studyHours && i < sessions - 1) {
            double breakEnd = currentHour + (10 / 60); // 10 minutes
            daySchedule.add({
              'type': 'break',
              'startTime': currentHour,
              'endTime': breakEnd,
            });
            currentHour = breakEnd;
          }
        }
      }

      generatedTimetable.add({'day': day, 'schedule': daySchedule});
    }
  }

  int _getDifficultyPriority(String difficulty) {
    switch (difficulty) {
      case 'Hard':
        return 3;
      case 'Medium':
        return 2;
      case 'Easy':
        return 1;
      default:
        return 2;
    }
  }

  Color _getSubjectColor(String subjectName) {
    int index = subjectName.hashCode % _subjectColors.length;
    return _subjectColors[index];
  }

  String _formatTime(double hour) {
    int hours = hour.floor();
    int minutes = ((hour - hours) * 60).round();
    String period = hours >= 12 ? 'PM' : 'AM';

    if (hours > 12) hours -= 12;
    if (hours == 0) hours = 12;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} $period';
  }

  IconData _getSubjectIcon(String subjectName) {
    for (var key in _subjectIcons.keys) {
      if (subjectName.toLowerCase().contains(key.toLowerCase())) {
        return _subjectIcons[key]!;
      }
    }
    return Icons.book; // Default icon
  }

  void _regeneratePlan() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TimetableInputPage()),
    );
  }

  void _saveTimetable() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Timetable saved successfully!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View All',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Go back to dashboard
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Your Smart Study Plan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveTimetable,
            tooltip: 'Save Timetable',
          ),
        ],
      ),
      body: isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF673AB7),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Generating your personalized timetable...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
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
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Study Plan Ready!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.timetableData['daysPerWeek']} days • ${widget.timetableData['studyHours']} hours/day • ${widget.timetableData['subjects'].length} subjects',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Timetable List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: generatedTimetable.length,
                    itemBuilder: (context, index) {
                      var dayData = generatedTimetable[index];
                      return _buildDayCard(dayData);
                    },
                  ),
                ),

                // Bottom Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _regeneratePlan,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Regenerate'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF673AB7),
                                side: const BorderSide(
                                  color: Color(0xFF673AB7),
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveTimetable,
                              icon: const Icon(Icons.download),
                              label: const Text('Save'),
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
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.home, size: 18),
                          label: const Text('Back to Dashboard'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF673AB7),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> dayData) {
    int day = dayData['day'];
    List<dynamic> schedule = dayData['schedule'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF673AB7).withOpacity(0.1),
                  const Color(0xFF9C27B0).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF673AB7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'D$day',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Day $day Schedule',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),

          // Schedule Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: schedule.map((slot) {
                if (slot['type'] == 'break') {
                  return _buildBreakSlot(slot);
                } else {
                  return _buildSubjectSlot(slot);
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectSlot(Map<String, dynamic> slot) {
    Color color = slot['color'];
    String subject = slot['subject'];
    String difficulty = slot['difficulty'];
    String startTime = _formatTime(slot['startTime']);
    String endTime = _formatTime(slot['endTime']);
    IconData icon = _getSubjectIcon(subject);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '$startTime - $endTime',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(
                      difficulty,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getDifficultyColor(difficulty),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakSlot(Map<String, dynamic> slot) {
    String startTime = _formatTime(slot['startTime']);
    String endTime = _formatTime(slot['endTime']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.coffee, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Break',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$startTime - $endTime (10 min)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Hard':
        return const Color(0xFFE91E63);
      case 'Medium':
        return const Color(0xFFFF9800);
      case 'Easy':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }
}
