import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_chat_service.dart';

class AiExplanationService {
  static Future<String> getExplanation({
    required String question,
    required String userAnswer,
    required String correctAnswer,
    String? context,
  }) async {
    final String prompt = '''
    You are a friendly AI Tutor for a student. The student just answered a question incorrectly.
    Provide a simple, encouraging, and easy-to-understand explanation of why the answer was wrong and how to find the correct one.
    
    QUESTION: $question
    USER'S WRONG ANSWER: $userAnswer
    CORRECT ANSWER: $correctAnswer
    ${context != null ? 'CONTEXT: $context' : ''}
    
    RULES:
    1. Keep it very simple (suitable for a child/student).
    2. Be encouraging (e.g., "Good try!", "Don't worry!").
    3. Explain the logic clearly.
    4. Keep it under 3-4 sentences.
    5. Use emojis.
    ''';

    try {
      return await AiChatService.getResponse(prompt);
    } catch (e) {
      return "Don't worry! The correct answer is $correctAnswer. Keep practicing and you'll get it next time! 🌟";
    }
  }

  static Future<Map<String, dynamic>> getSimilarQuestion({
    required String originalQuestion,
    required String questionType,
    String? context,
  }) async {
    final String prompt = '''
    Generate a SIMILAR but DIFFERENT question of the same type based on the original one.
    Return only a JSON object.
    
    ORIGINAL QUESTION: $originalQuestion
    QUESTION TYPE: $questionType
    ${context != null ? 'CONTEXT: $context' : ''}
    
    OUTPUT FORMAT:
    {
      "question": "The new question",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct": "The correct option",
      "type": "$questionType"
    }
    ''';

    try {
      String response = await AiChatService.getResponse(prompt);
      // Extract JSON
      if (response.contains('```json')) {
        response = response.split('```json')[1].split('```')[0].trim();
      } else if (response.contains('```')) {
        response = response.split('```')[1].split('```')[0].trim();
      }
      return jsonDecode(response);
    } catch (e) {
      return {};
    }
  }
}
