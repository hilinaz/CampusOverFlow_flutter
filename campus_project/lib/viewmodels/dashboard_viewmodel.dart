import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/api_config.dart';

class DashboardViewModel extends ChangeNotifier {
  int _totalUsers = 0;
  int _totalQuestions = 0;
  int _totalAnswers = 0;
  bool _isLoading = false;
  String? _error;

  final String _baseUrl = ApiConfig.baseUrl;
  final String _authToken;

  DashboardViewModel({required String authToken}) : _authToken = authToken;

  int get totalUsers => _totalUsers;
  int get totalQuestions => _totalQuestions;
  int get totalAnswers => _totalAnswers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.wait([
      _fetchUsersCount(),
      _fetchQuestionsCount(),
      _fetchAnswersCount(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchUsersCount() async {
    try {
      final uri = Uri.parse('$_baseUrl/users/getUserStats');
      if (kDebugMode) print('Fetching users count from: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (kDebugMode) {
        print('Users Count Response Status Code: ${response.statusCode}');
        print('Users Count Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _totalUsers = data['totalUsers'] ?? 0;
      } else {
        String errorMessage =
            'Failed to load user count: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData.containsKey('message') &&
              errorData['message'] is String) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('msg') &&
              errorData['msg'] is String) {
            errorMessage = errorData['msg'];
          }
        } catch (e) {
          if (kDebugMode) print('Error decoding user count error response: $e');
        }
        _error = errorMessage;
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching users count (catch block): $e');
      _error = 'Failed to connect to server for users count';
    }
  }

  Future<void> _fetchQuestionsCount() async {
    try {
      final uri = Uri.parse('$_baseUrl/question/countQuestions');
      if (kDebugMode) print('Fetching questions count from: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (kDebugMode) {
        print('Questions Count Response Status Code: ${response.statusCode}');
        print('Questions Count Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _totalQuestions = data['totalQuestions'] ?? 0;
      } else {
        String errorMessage =
            'Failed to load question count: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData.containsKey('message') &&
              errorData['message'] is String) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('msg') &&
              errorData['msg'] is String) {
            errorMessage = errorData['msg'];
          }
        } catch (e) {
          if (kDebugMode)
            print('Error decoding question count error response: $e');
        }
        _error = errorMessage;
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching questions count (catch block): $e');
      _error = 'Failed to connect to server for questions count';
    }
  }

  Future<void> _fetchAnswersCount() async {
    try {
      final uri = Uri.parse('$_baseUrl/answers/stats');
      if (kDebugMode) print('Fetching answers count from: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (kDebugMode) {
        print('Answers Count Response Status Code: ${response.statusCode}');
        print('Answers Count Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _totalAnswers = data['totalAnswers'] ?? 0;
      } else {
        String errorMessage =
            'Failed to load answer count: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData.containsKey('message') &&
              errorData['message'] is String) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('msg') &&
              errorData['msg'] is String) {
            errorMessage = errorData['msg'];
          }
        } catch (e) {
          if (kDebugMode)
            print('Error decoding answer count error response: $e');
        }
        _error = errorMessage;
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching answers count (catch block): $e');
      _error = 'Failed to connect to server for answers count';
    }
  }
}
