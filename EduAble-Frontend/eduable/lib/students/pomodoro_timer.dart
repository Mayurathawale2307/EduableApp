import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  Timer? _timer;
  int _seconds = 25 * 60; // 25 minutes
  bool _isRunning = false;
  int _sessionsCompleted = 0;
  String _mode = 'Focus'; // Focus, Short Break, Long Break

  // Audio players for different modes
  final AudioPlayer _focusMusicPlayer = AudioPlayer();
  final AudioPlayer _breakMusicPlayer = AudioPlayer();

  // Music controls
  bool _isMusicEnabled = true;
  double _musicVolume = 0.3; // Default low volume (30%)
  bool _isMusicPlaying = false;

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _startMusic(); // Start music when timer starts
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer?.cancel();
        _handleTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pauseMusic(); // Pause music when timer pauses
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _stopMusic(); // Stop music when timer resets
    setState(() {
      _seconds = _mode == 'Focus'
          ? 25 * 60
          : (_mode == 'Short Break' ? 5 * 60 : 15 * 60);
      _isRunning = false;
    });
  }

  void _handleTimerComplete() {
    _stopMusic(); // Stop music when timer completes

    if (_mode == 'Focus') {
      setState(() {
        _sessionsCompleted++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Focus session complete! Take a break.'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 3),
        ),
      );
      // Switch to break
      setState(() {
        _mode = _sessionsCompleted % 4 == 0 ? 'Long Break' : 'Short Break';
        _seconds = _mode == 'Long Break' ? 15 * 60 : 5 * 60;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Break over! Ready to focus?'),
          backgroundColor: Color(0xFF2196F3),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _mode = 'Focus';
        _seconds = 25 * 60;
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Music Control Methods
  Future<void> _startMusic() async {
    if (!_isMusicEnabled) return;

    try {
      // Stop all players first
      await _focusMusicPlayer.stop();
      await _breakMusicPlayer.stop();

      if (_mode == 'Focus') {
        // Use a calm study music URL (royalty-free)
        await _focusMusicPlayer.setSourceUrl(
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        );
        await _focusMusicPlayer.setVolume(_musicVolume);
        await _focusMusicPlayer.setReleaseMode(ReleaseMode.loop);
        await _focusMusicPlayer.resume();
        setState(() {
          _isMusicPlaying = true;
        });
      } else {
        // Use relaxing break music
        await _breakMusicPlayer.setSourceUrl(
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        );
        await _breakMusicPlayer.setVolume(_musicVolume);
        await _breakMusicPlayer.setReleaseMode(ReleaseMode.loop);
        await _breakMusicPlayer.resume();
        setState(() {
          _isMusicPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Music playback error: $e');
      // Fallback: just set the state
      setState(() {
        _isMusicPlaying = false;
      });
    }
  }

  Future<void> _pauseMusic() async {
    try {
      if (_mode == 'Focus') {
        await _focusMusicPlayer.pause();
      } else {
        await _breakMusicPlayer.pause();
      }
      setState(() {
        _isMusicPlaying = false;
      });
    } catch (e) {
      debugPrint('Music pause error: $e');
    }
  }

  Future<void> _stopMusic() async {
    try {
      await _focusMusicPlayer.stop();
      await _breakMusicPlayer.stop();
      setState(() {
        _isMusicPlaying = false;
      });
    } catch (e) {
      debugPrint('Music stop error: $e');
    }
  }

  Future<void> _toggleMusic() async {
    setState(() {
      _isMusicEnabled = !_isMusicEnabled;
    });

    if (_isMusicEnabled && _isRunning) {
      await _startMusic();
    } else {
      await _stopMusic();
    }
  }

  Future<void> _setVolume(double volume) async {
    setState(() {
      _musicVolume = volume;
    });

    try {
      await _focusMusicPlayer.setVolume(volume);
      await _breakMusicPlayer.setVolume(volume);
    } catch (e) {
      debugPrint('Volume set error: $e');
    }
  }

  void _switchMode(String newMode) {
    _timer?.cancel();
    _stopMusic(); // Stop music when switching modes
    setState(() {
      _mode = newMode;
      _seconds = newMode == 'Focus'
          ? 25 * 60
          : (newMode == 'Short Break' ? 5 * 60 : 15 * 60);
      _isRunning = false;
      _isMusicPlaying = false;
    });

    // If timer was running, restart with new mode
    if (_isMusicEnabled) {
      // Music will start when user clicks Start again
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusMusicPlayer.dispose();
    _breakMusicPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = _mode == 'Focus'
        ? const Color(0xFFE91E63)
        : (_mode == 'Short Break'
              ? const Color(0xFF4CAF50)
              : const Color(0xFF2196F3));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          '$_mode Timer',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: themeColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Mode Selector
            Container(
              padding: const EdgeInsets.all(4),
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
              child: Row(
                children: [
                  _buildModeButton('Focus', const Color(0xFFE91E63)),
                  _buildModeButton('Short Break', const Color(0xFF4CAF50)),
                  _buildModeButton('Long Break', const Color(0xFF2196F3)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Timer Display
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [themeColor, themeColor.withOpacity(0.7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_seconds),
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _mode,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Music Controls
            Container(
              padding: const EdgeInsets.all(16),
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
                children: [
                  Row(
                    children: [
                      Icon(
                        _isMusicEnabled ? Icons.music_note : Icons.music_off,
                        color: _isMusicEnabled ? themeColor : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isMusicEnabled
                                  ? 'Background Music'
                                  : 'Music Disabled',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isMusicPlaying
                                  ? 'Now Playing: ${_mode == 'Focus' ? 'Study Music 🎧' : 'Relax Music 🌿'}'
                                  : 'Music Paused',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isMusicEnabled,
                        onChanged: (value) => _toggleMusic(),
                        activeThumbColor: themeColor,
                      ),
                    ],
                  ),
                  if (_isMusicEnabled) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.volume_down,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: _musicVolume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            activeColor: themeColor,
                            onChanged: (value) => _setVolume(value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.volume_up,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(_musicVolume * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text('Start', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause, size: 28),
                    label: const Text('Pause', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh, size: 28),
                  label: const Text('Reset', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Sessions Completed
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Color(0xFFFF9800),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$_sessionsCompleted Sessions Completed',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Keep up the great work!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2196F3), width: 2),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pomodoro Technique Tips:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Focus for 25 minutes'),
                  Text('• Take a 5-minute short break'),
                  Text('• After 4 sessions, take a 15-minute long break'),
                  Text('• Stay focused and avoid distractions'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode, Color color) {
    bool isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            mode.split(' ')[0],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
