import 'package:flutter/material.dart';
import '../services/weakness_detection_service.dart';

class WeaknessEnginePage extends StatefulWidget {
  const WeaknessEnginePage({super.key});

  @override
  State<WeaknessEnginePage> createState() => _WeaknessEnginePageState();
}

class _WeaknessEnginePageState extends State<WeaknessEnginePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _analysisData;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    // Simulated data for demonstration - in a real app, this would come from the database/state
    final quizData = [
      {"topic": "Fractions", "score": 3, "total": 10},
      {"topic": "Algebra", "score": 8, "total": 10},
      {"topic": "Science", "score": 4, "total": 10},
    ];
    final gameData = [
      {"game_type": "Memory", "score": 40},
      {"game_type": "Focus", "score": 85},
    ];

    try {
      final result = await WeaknessDetectionService.analyzePerformance(
        quizResults: quizData,
        gameResults: gameData,
      );
      if (mounted) {
        setState(() {
          _analysisData = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('AI Learning Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF6B9D),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B9D)))
          : _analysisData == null
              ? const Center(child: Text('No data available for analysis'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('🧠 Deep Analysis'),
                      ...(_analysisData!['analysis'] as List).map((item) => _buildAnalysisItem(item)),
                      const SizedBox(height: 24),
                      _buildSectionTitle('🚀 Improvement Plan'),
                      ...(_analysisData!['improvement_plan'] as List).map((item) => _buildPlanItem(item)),
                      const SizedBox(height: 24),
                      _buildStrategyCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF9A9E)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          const Text('Performance Snapshot', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Weak Topics', _analysisData!['weak_topics'].length.toString(), Colors.white),
              _buildStat('Strong Topics', _analysisData!['strong_topics'].length.toString(), Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
      ],
    );
  }

  Widget _buildAnalysisItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.red.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(item['area'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(item['issue'], style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
          const SizedBox(height: 4),
          Text('Reason: ${item['reason']}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPlanItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.green.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['area'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
          const SizedBox(height: 12),
          ...(item['actions'] as List).map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(action, style: const TextStyle(fontSize: 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStrategyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Personalized Strategy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_analysisData!['personalized_strategy'], style: const TextStyle(fontSize: 15, color: Color(0xFF1565C0), height: 1.5)),
        ],
      ),
    );
  }
}
