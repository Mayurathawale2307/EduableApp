import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AppProvider extends ChangeNotifier {
  final ApiService apiService;
  final SharedPreferences prefs;

  AppProvider({required this.apiService, required this.prefs}) {
    _loadUserData();
  }

  // User state
  UserModel? _user;
  String? _token;
  String? _userRole;
  String _userName = '';
  String _userEmail = '';
  String? _userDisability;
  Map<String, dynamic>? _userAssessmentResults;

  // UI preferences
  String _fontSize = 'normal';
  bool _darkMode = false;
  bool _highContrast = false;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  String? get userRole => _userRole;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get userDisability => _userDisability;
  Map<String, dynamic>? get userAssessmentResults => _userAssessmentResults;
  String get fontSize => _fontSize;
  bool get darkMode => _darkMode;
  bool get highContrast => _highContrast;

  // Font size getters
  double get fontSizeValue {
    switch (_fontSize) {
      case 'large':
        return 18.0;
      case 'xlarge':
        return 22.0;
      default:
        return 16.0;
    }
  }

  void _loadUserData() {
    final storedToken = prefs.getString('eduableToken');
    final storedUserJson = prefs.getString('eduableUser');

    if (storedToken != null && storedUserJson != null) {
      try {
        _token = storedToken;
        final userData = jsonDecode(storedUserJson);
        _user = UserModel.fromJson(userData);
        _userRole = userData['role'];
        _userName = userData['name'] ?? '';
        _userEmail = userData['email'] ?? '';
        _userDisability = userData['disability'];
        _userAssessmentResults = userData['assessmentResults'];
        notifyListeners();
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiService.login(email, password);
      
      if (response.statusCode == 200) {
        final data = response.data;
        _token = data['token'];
        _user = UserModel.fromJson(data);
        _userRole = data['role'];
        _userName = data['name'] ?? '';
        _userEmail = data['email'] ?? '';
        _userDisability = data['disability'];
        _userAssessmentResults = data['assessmentResults'];

        // Save to preferences
        await prefs.setString('eduableToken', _token!);
        await prefs.setString('eduableUser', jsonEncode(data));

        notifyListeners();
        return {'success': true, 'user': data};
      } else {
        return {'success': false, 'message': response.data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password, {String role = 'student'}) async {
    try {
      final response = await apiService.register(name, email, password, role: role);
      
      if (response.statusCode == 200) {
        final data = response.data;
        _token = data['token'];
        _user = UserModel.fromJson(data);
        _userRole = data['role'];
        _userName = data['name'] ?? '';
        _userEmail = data['email'] ?? '';
        _userDisability = data['disability'];
        _userAssessmentResults = data['assessmentResults'];

        // Save to preferences
        await prefs.setString('eduableToken', _token!);
        await prefs.setString('eduableUser', jsonEncode(data));

        notifyListeners();
        return {'success': true, 'user': data};
      } else {
        return {'success': false, 'message': response.data['message'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> saveDisabilityAssessment(String disabilityType, Map<String, dynamic> results) async {
    if (_token == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    try {
      final response = await apiService.updateAssessment(disabilityType, results);
      
      if (response.statusCode == 200) {
        final data = response.data;
        _userDisability = data['disability'];
        _userAssessmentResults = data['assessmentResults'];

        // Update stored user data
        final storedUserJson = prefs.getString('eduableUser');
        if (storedUserJson != null) {
          final userData = jsonDecode(storedUserJson);
          userData['disability'] = _userDisability;
          userData['assessmentResults'] = _userAssessmentResults;
          await prefs.setString('eduableUser', jsonEncode(userData));
        }

        notifyListeners();
        return {'success': true, 'user': data};
      } else {
        return {'success': false, 'message': response.data['message'] ?? 'Failed to save assessment'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  void logout() {
    _token = null;
    _user = null;
    _userRole = null;
    _userName = '';
    _userEmail = '';
    _userDisability = null;
    _userAssessmentResults = null;

    prefs.remove('eduableToken');
    prefs.remove('eduableUser');

    notifyListeners();
  }

  void increaseFontSize() {
    if (_fontSize == 'normal') {
      _fontSize = 'large';
    } else if (_fontSize == 'large') {
      _fontSize = 'xlarge';
    }
    notifyListeners();
  }

  void decreaseFontSize() {
    if (_fontSize == 'xlarge') {
      _fontSize = 'large';
    } else if (_fontSize == 'large') {
      _fontSize = 'normal';
    }
    notifyListeners();
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  void toggleHighContrast() {
    _highContrast = !_highContrast;
    notifyListeners();
  }
}

