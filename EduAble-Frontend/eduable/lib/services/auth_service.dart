import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://eduable-backend-m097.onrender.com/api';

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'userType': userType,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('userId', data['_id'] ?? '');
          await prefs.setString('userName', data['name'] ?? '');
          await prefs.setString('userEmail', data['email'] ?? '');
          await prefs.setString('userType', data['userType'] ?? '');
        }
        return {
          'success': true,
          'message': 'Account created successfully',
          'data': data,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Signup failed',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Request timed out. Please check your internet connection and try again.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message':
            'Network error: Unable to connect to server. Please ensure backend is running on $baseUrl',
      };
    } on FormatException {
      return {'success': false, 'message': 'Invalid response from server'};
    } catch (e) {
      return {'success': false, 'message': 'Signup failed: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('userId', data['_id'] ?? '');
          await prefs.setString('userName', data['name'] ?? '');
          await prefs.setString('userEmail', data['email'] ?? '');
          await prefs.setString('userType', data['userType'] ?? '');
        }
        return {'success': true, 'message': 'Login successful', 'data': data};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Request timed out. Please check your internet connection and try again.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message':
            'Network error: Unable to connect to server. Please ensure backend is running on $baseUrl',
      };
    } on FormatException {
      return {'success': false, 'message': 'Invalid response from server'};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/auth/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get profile',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Request timed out. Please check your internet connection and try again.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message': 'Network error: Unable to connect to server',
      };
    } on FormatException {
      return {'success': false, 'message': 'Invalid response from server'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get profile: ${e.toString()}',
      };
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userType');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
