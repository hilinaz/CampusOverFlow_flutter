import 'package:dio/dio.dart';
import 'package:campus_project/models/user_model.dart';
import 'package:campus_project/config/api_config.dart';
import 'package:flutter/foundation.dart';

class SignupRepository {
  final Dio _dio;
  final String _baseUrl = ApiConfig.baseUrl;

  SignupRepository() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
    // Set timeout configurations
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
  }

  Future<User?> signup(User user) async {
    try {
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
      debugPrint('URL: ${_baseUrl}/users/register');
      debugPrint('Request Headers: ${_dio.options.headers}');
      debugPrint('Request Body: $userData');

      final response = await _dio.post(
        '/users/register',
        data: userData,
      );

      debugPrint('=== Signup Response Details ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.data}');
      // debugPrint('Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> userData = response.data['user'];
        final String? token = response.data['token'];

        if (token != null) {
          userData['token'] = token;
        }

        return User.fromJson(userData);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data['message'] ??
              response.data['msg'] ??
              'Signup failed',
        );
      }
    } on DioException catch (e) {
      debugPrint('=== Signup Error Details ===');
      debugPrint('Error Type: ${e.type}');
      debugPrint('Error Message: ${e.message}');

      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage =
              'Connection timed out. Please check your internet connection and try again.';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage =
              'Request timed out while sending data. Please try again.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage =
              'Request timed out while receiving data. Please try again.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = e.response?.data['message'] ??
              e.response?.data['msg'] ??
              'Server error occurred. Please try again.';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled. Please try again.';
          break;
        case DioExceptionType.connectionError:
          errorMessage =
              'Unable to connect to the server. Please check your internet connection.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Please try again.';
      }

      if (e.response != null) {
        debugPrint('Response Status: ${e.response?.statusCode}');
        debugPrint('Response Data: ${e.response?.data}');
      }
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
}
