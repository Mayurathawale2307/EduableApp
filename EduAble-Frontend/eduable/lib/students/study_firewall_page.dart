import 'dart:async';
import 'package:flutter/material.dart';

class StudyFirewallPage extends StatefulWidget {
  const StudyFirewallPage({super.key});

  @override
  State<StudyFirewallPage> createState() => _StudyFirewallPageState();
}

class _StudyFirewallPageState extends State<StudyFirewallPage> with WidgetsBindingObserver {
  bool _isFirewallActive = false;
  int _secondsRemaining = 25 * 60;
  Timer? _timer;
  int _distractionsBlocked = 0;
  double _focusScore = 100.0;
  bool _wasAppPaused = false;

  final List<Map<String, dynamic>> _blockedApps = [
    {'name': 'YouTube', 'icon': Icons.play_circle_filled, 'blocked': true},
    {'name': 'Instagram', 'icon': Icons.camera_alt, 'blocked': true},
    {'name': 'TikTok', 'icon': Icons.music_note, 'blocked': true},
    {'name': 'Snapchat', 'icon': Icons.chat_bubble, 'blocked': true},
    {'name': 'Facebook', 'icon': Icons.facebook, 'blocked': true},
    {'name': 'WhatsApp', 'icon': Icons.message, 'blocked': true},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isFirewallActive) {
      if (state == AppLifecycleState.paused) {
        _wasAppPaused = true;
      } else if (state == AppLifecycleState.resumed && _wasAppPaused) {
        _handleFirewallBreach();
        _wasAppPaused = false;
      }
    }
  }

  void _handleFirewallBreach() {
    setState(() {
      _distractionsBlocked++;
      _focusScore = (_focusScore - 5).clamp(0, 100);
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Firewall Alert!'),
          ],
        ),
        content: const Text(
          'You tried to leave the study zone! The Study Firewall has blocked a distraction. Stay focused to keep your score high.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Study'),
          ),
        ],
      ),
    );
  }

  void _toggleFirewall() {
    setState(() {
      _isFirewallActive = !_isFirewallActive;
      if (_isFirewallActive) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          // Small focus score boost for staying in
          if (_secondsRemaining % 60 == 0) {
            _focusScore = (_focusScore + 1).clamp(0, 100);
          }
        });
      } else {
        _timer?.cancel();
        _handleSessionComplete();
      }
    });
  }

  void _handleSessionComplete() {
    setState(() {
      _isFirewallActive = false;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Success!'),
        content: Text(
          'Congratulations! You stayed behind the firewall for 25 minutes.\n\nFocus Score: ${_focusScore.toInt()}%\nDistractions Blocked: $_distractionsBlocked',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate for firewall feel
      appBar: AppBar(
        title: const Text(
          'Study Firewall',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Firewall Status Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isFirewallActive 
                    ? Colors.red.withOpacity(0.1) 
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isFirewallActive ? Colors.red : Colors.blue,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _isFirewallActive ? Icons.shield : Icons.shield_outlined,
                    size: 64,
                    color: _isFirewallActive ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isFirewallActive ? 'FIREWALL ACTIVE' : 'FIREWALL INACTIVE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isFirewallActive ? Colors.red : Colors.blue,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isFirewallActive 
                        ? 'Distractions are being blocked' 
                        : 'Secure your study session now',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Timer and Score Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Time Left',
                    _formatTime(_secondsRemaining),
                    Icons.timer,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Focus Score',
                    '${_focusScore.toInt()}%',
                    Icons.bolt,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Distractions Blocked Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Distraction Firewall',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$_distractionsBlocked Blocked',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _blockedApps.map((app) => _buildBlockedAppChip(app)).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Start/Stop Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _toggleFirewall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFirewallActive ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: (_isFirewallActive ? Colors.red : Colors.blue).withOpacity(0.5),
                ),
                child: Text(
                  _isFirewallActive ? 'DISABLE FIREWALL' : 'ACTIVATE FIREWALL',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text(
              'USP: The Study Firewall monitors your focus and blocks digital distractions to ensure deep work sessions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedAppChip(Map<String, dynamic> app) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _isFirewallActive ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFirewallActive ? Colors.red.withOpacity(0.3) : Colors.white10,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(app['icon'], size: 16, color: _isFirewallActive ? Colors.red : Colors.white54),
          const SizedBox(width: 8),
          Text(
            app['name'],
            style: TextStyle(
              color: _isFirewallActive ? Colors.red.withOpacity(0.8) : Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_isFirewallActive) ...[
            const SizedBox(width: 4),
            const Icon(Icons.lock, size: 12, color: Colors.red),
          ],
        ],
      ),
    );
  }
}
