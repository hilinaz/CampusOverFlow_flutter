import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/question_model.dart';
import 'package:flutter/foundation.dart';

class QuestionRepository {
  final Dio _dio;

  QuestionRepository({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
  }

  Future<List<Question>> fetchQuestions(String authToken) async {
    try {
      debugPrint('Fetching questions from: ${ApiConfig.baseUrl}/question');
      final response = await _dio.get(
        '/question',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        }),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> questionsJson = response.data['allQuestion'];
        final questions =
            questionsJson.map((json) => Question.fromJson(json)).toList();
        debugPrint('Fetched ${questions.length} questions');
        return questions;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load questions');
      }
    } on DioException catch (e) {
      debugPrint('Error fetching questions: ${e.message}');
      if (e.response != null) {
        debugPrint('Error response: ${e.response?.data}');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load questions');
    }
  }

  Future<List<Question>> searchQuestions(String authToken, String query) async {
    try {
      debugPrint('Searching questions with query: $query');
      final response = await _dio.get(
        '/question/search/$query',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        }),
      );

      debugPrint('Search response status code: ${response.statusCode}');
      debugPrint('Search response body: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> questionsJson = response.data['allQuestion'];
        final questions =
            questionsJson.map((json) => Question.fromJson(json)).toList();
        debugPrint(
            'Found ${questions.length} questions for search query: $query');
        return questions;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to search questions');
      }
    } on DioException catch (e) {
      debugPrint('Error searching questions: ${e.message}');
      if (e.response != null) {
        debugPrint('Error response: ${e.response?.data}');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to search questions');
    }
  }

  Future<void> createQuestion({
    required String authToken,
    required String title,
    required String description,
    required String tag,
  }) async {
    try {
      final response = await _dio.post(
        '/question',
        data: {
          'title': title,
          'description': description,
          'tag': tag,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(response.data['msg'] ?? 'Failed to create question');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['msg'] != null) {
        throw Exception(e.response?.data['msg']);
      }
      throw Exception('Failed to connect to server');
    }
  }

  Future<void> updateQuestion({
    required String authToken,
    required String questionId,
    required String title,
    required String description,
    required String tag,
  }) async {
    try {
      final response = await _dio.patch(
        '/question/$questionId',
        data: {
          'title': title,
          'description': description,
          'tag': tag,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['msg'] ?? 'Failed to update question');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['msg'] != null) {
        throw Exception(e.response?.data['msg']);
      }
      throw Exception('Failed to connect to server');
    }
  }

  Future<void> deleteQuestion(String authToken, String questionId) async {
    try {
      await _dio.delete(
        '/question/$questionId',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        }),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to delete question');
    }
  }
}
