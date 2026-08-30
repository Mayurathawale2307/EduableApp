import 'dart:convert';
import 'package:http/http.dart' as http;

class AiChatService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  static Future<String> getResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://eduable.app',
          'X-Title': 'EduAble App',
        },
        body: jsonEncode({
          'model': 'openai/gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': 'You are a friendly and helpful AI Tutor for students. Follow these rules:\n1. Use **bold** for key terms and concepts.\n2. Use bullet points or numbered lists for clear steps and explanations.\n3. For mathematical formulas, use plain text or standard markdown (e.g., P = W/t instead of complex LaTeX).\n4. Keep your answers concise, educational, and easy for a student to understand.\n5. Use emojis where appropriate to keep it engaging.'},
            {'role': 'user', 'content': userMessage},
          ],
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'Sorry, I couldn\'t process that.';
      } else {
        return 'Error: API returned status ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
