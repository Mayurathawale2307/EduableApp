import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        await _flutterTts.setLanguage("en-US");
        await _flutterTts.setSpeechRate(0.4); // Slower for clarity
        await _flutterTts.setVolume(1.0); // Maximum volume
        await _flutterTts.setPitch(0.9); // Lower pitch for male voice
        
        // Try to set a male voice if available
        try {
          var voices = await _flutterTts.getVoices;
          // Look for male or deep voice
          for (var voice in voices) {
            String voiceName = voice.toString().toLowerCase();
            if (voiceName.contains('male') || 
                voiceName.contains('david') || 
                voiceName.contains('james') ||
                voiceName.contains('google')) {
              await _flutterTts.setVoice(voice);
              break;
            }
          }
        } catch (e) {
          debugPrint('Voice selection error: $e');
        }
        
        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 200));
        _isInitialized = true;
      } catch (e) {
        debugPrint('TTS Initialization Error: $e');
        _isInitialized = false;
      }
    }
  }

  Future<void> speak(String text) async {
    try {
      await initialize();
      if (_isInitialized) {
        await _flutterTts.stop(); // Stop any current speech
        await Future.delayed(const Duration(milliseconds: 50));
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint('TTS Speak Error: $e');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
  }
}
