import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../config/api_config.dart';

class SignupViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  final String _baseUrl = ApiConfig.baseUrl;
  String? _token;
  String? _firstName;
  String? _lastName;
  String? _profession;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get profession => _profession;

  Future<bool> signup(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '$_baseUrl/users/register';
      // Create a map with only the fields needed for registration
      final userData = {
        'username': user.username,
        'firstname': user.firstName,
        'lastname': user.lastName,
        'profession': user.profession,
        'email': user.email,
        'password': user.password,
      };

      debugPrint('=== Signup Request Details ===');
      debugPrint('URL: $url');
      debugPrint('Request Headers: {"Content-Type": "application/json"}');
      debugPrint('Request Body: ${json.encode(userData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      debugPrint('=== Signup Response Details ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        _token = responseData['token'];
        _firstName = user.firstName;
        _lastName = user.lastName;
        _profession = user.profession;

        debugPrint('Signup successful. Token received: ${_token != null}');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ??
            errorData['msg'] ??
            'Signup failed with status code: ${response.statusCode}';
        debugPrint('Signup failed: $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('=== Signup Error Details ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      _error =
          'Network error occurred. Please check your connection and try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
