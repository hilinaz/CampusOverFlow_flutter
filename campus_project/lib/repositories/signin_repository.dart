import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'package:flutter/foundation.dart';

class SigninRepository {
  final Dio _dio;
  final String _baseUrl = ApiConfig.baseUrl;

  SigninRepository() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
    // Set timeout configurations
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.sendTimeout = const Duration(seconds: 10);
  }

  Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('=== Signin Request Details ===');
      debugPrint('URL: ${_baseUrl}/users/login');
      debugPrint('Request Headers: ${_dio.options.headers}');
      debugPrint('Request Body: {"email": "$email", "password": "****"}');

      final response = await _dio.post(
        '/users/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      debugPrint('=== Signin Response Details ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'token': data['token'],
          'roleId': data['user']['role_id'],
          'firstname': data['user']['firstname'],
          'lastname': data['user']['lastname'],
          'profession': data['user']['profession'],
        };
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data['msg'] ?? 'Sign in failed',
        );
      }
    } on DioException catch (e) {
      debugPrint('=== Signin Error Details ===');
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
          errorMessage = e.response?.data['msg'] ??
              e.response?.data['message'] ??
              'Invalid email or password.';
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
