import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('eduableToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // Auth endpoints
  Future<Response> login(String email, String password) async {
    try {
      return await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> register(String name, String email, String password, {String role = 'student'}) async {
    try {
      return await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Assessment endpoints
  Future<Response> updateAssessment(String disability, Map<String, dynamic> results) async {
    try {
      return await _dio.put('/assessment/update', data: {
        'disability': disability,
        'assessmentResults': results,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Learning endpoints
  Future<Response> getPersonalizedLesson(String childId) async {
    try {
      return await _dio.get('/learning/personalized-lesson/$childId');
    } catch (e) {
      rethrow;
    }
  }

  // Progress endpoints
  Future<Response> getProgress(String userId) async {
    try {
      return await _dio.get('/progress/$userId');
    } catch (e) {
      rethrow;
    }
  }

  // Parent endpoints
  Future<Response> getParentInsights(String parentId) async {
    try {
      return await _dio.get('/parent-insights/$parentId');
    } catch (e) {
      rethrow;
    }
  }

  // Lesson endpoints
  Future<Response> getLessons() async {
    try {
      return await _dio.get('/lessons');
    } catch (e) {
      rethrow;
    }
  }

  // Sync endpoints
  Future<Response> syncData(Map<String, dynamic> data) async {
    try {
      return await _dio.post('/sync', data: data);
    } catch (e) {
      rethrow;
    }
  }
}

