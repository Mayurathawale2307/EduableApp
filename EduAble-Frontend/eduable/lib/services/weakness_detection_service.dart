import 'dart:convert';
import 'ai_chat_service.dart';

class WeaknessDetectionService {
  static Future<Map<String, dynamic>> analyzePerformance({
    required List<Map<String, dynamic>> quizResults,
    required List<Map<String, dynamic>> gameResults,
  }) async {
    // 1. Initial Local Analysis
    List<String> weakTopics = [];
    List<String> strongTopics = [];
    List<String> weakSkills = [];
    List<String> strongSkills = [];

    for (var quiz in quizResults) {
      double percentage = (quiz['score'] / quiz['total']) * 100;
      if (percentage < 50) {
        weakTopics.add(quiz['topic']);
      } else {
        strongTopics.add(quiz['topic']);
      }
    }

    for (var game in gameResults) {
      if (game['score'] < 50) {
        weakSkills.add(game['game_type']);
      } else {
        strongSkills.add(game['game_type']);
      }
    }

    // 2. AI-Powered Deep Analysis & Plan Generation
    final String prompt = '''
    Analyze this student performance data and return a JSON response following the EXACT format provided.
    
    DATA:
    {
      "quiz_results": ${jsonEncode(quizResults)},
      "game_results": ${jsonEncode(gameResults)}
    }
    
    RULES:
    - Quiz score < 50% is WEAK academic topic.
    - Game score < 50 is WEAK cognitive skill.
    - Explain WHY in simple, student-friendly language.
    - Generate specific, actionable improvement actions.
    - Keep it encouraging and child-friendly.
    
    OUTPUT FORMAT:
    {
      "weak_topics": ["Topic1"],
      "strong_topics": ["Topic2"],
      "weak_skills": ["Skill1"],
      "strong_skills": ["Skill2"],
      "analysis": [
        { "area": "Topic1", "issue": "Short explanation", "reason": "Technical reason" }
      ],
      "improvement_plan": [
        { "area": "Topic1", "actions": ["Action 1", "Action 2"] }
      ],
      "personalized_strategy": "One line strategy"
    }
    ''';

    try {
      String aiResponse = await AiChatService.getResponse(prompt);
      // Attempt to extract JSON from AI response if it's wrapped in markdown
      if (aiResponse.contains('```json')) {
        aiResponse = aiResponse.split('```json')[1].split('```')[0].trim();
      } else if (aiResponse.contains('```')) {
        aiResponse = aiResponse.split('```')[1].split('```')[0].trim();
      }
      
      return jsonDecode(aiResponse);
    } catch (e) {
      // Fallback structured response if AI fails
      return {
        "weak_topics": weakTopics,
        "strong_topics": strongTopics,
        "weak_skills": weakSkills,
        "strong_skills": strongSkills,
        "analysis": weakTopics.map((t) => {"area": t, "issue": "Needs more practice", "reason": "Score below 50%"}).toList(),
        "improvement_plan": weakTopics.map((t) => {"area": t, "actions": ["Revise basic concepts", "Practice daily"]}).toList(),
        "personalized_strategy": "Focus on weak areas with daily practice."
      };
    }
  }
}
