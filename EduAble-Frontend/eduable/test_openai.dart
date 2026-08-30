import 'dart:convert';
import 'package:http/http.dart' as http;

// Simple test script to verify OpenRouter API connection
// Run this with: dart test_openai.dart

void main() async {
  print('🧪 Testing OpenRouter API Connection...\n');

  const String apiKey =
      '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';

  print(
    '📡 Testing connection to: https://openrouter.ai/api/v1/chat/completions',
  );
  print('🔑 API Key: ${apiKey.substring(0, 20)}...\n');

  try {
    final client = http.Client();
    final uri = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://eduable.app',
        'X-Title': 'EduAble App',
      })
      ..body = jsonEncode({
        'model': 'openai/gpt-4o-mini',
        'messages': [
          {'role': 'user', 'content': 'Say hello in one word'},
        ],
        'max_tokens': 10,
      });

    print('⏳ Sending request...');

    final streamedResponse = await client
        .send(request)
        .timeout(const Duration(seconds: 30));

    final response = await http.Response.fromStream(streamedResponse);

    print('\n✅ Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['choices'][0]['message']['content'];
      print('✅ API Response: $reply');
      print('\n🎉 SUCCESS! Your OpenRouter API key is working correctly!');
      print('📱 You can now use the EduAble app without any issues.');
    } else {
      print('❌ Error Response: ${response.body}');
      print('\n⚠️ API returned status: ${response.statusCode}');

      if (response.statusCode == 401) {
        print('🔴 Your API key is invalid or expired.');
      } else if (response.statusCode == 429) {
        print('🔴 API quota exceeded. Please wait or add credits.');
      }
    }

    client.close();
  } catch (e) {
    print('\n❌ Connection Failed!');
    print('Error: $e');
    print('\n🔍 Troubleshooting:');
    print('1. Check your internet connection');
    print('2. Make sure OpenRouter API is not blocked by firewall');
    print('3. Try running: ping openrouter.ai');
  }
}
