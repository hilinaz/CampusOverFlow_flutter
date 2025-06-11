import 'package:dio/dio.dart';
import '../models/answer_model.dart';
import '../config/api_config.dart';
import 'package:flutter/foundation.dart';

class AnswerRepository {
  final Dio _dio;
  final String _baseUrl = ApiConfig.baseUrl;

  AnswerRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<Answer>> getAnswers(String questionId, String authToken) async {
    try {
      final url = '$_baseUrl/answers/$questionId';
      debugPrint('=== Answer API Request Details ===');
      debugPrint('Base URL: $_baseUrl');
      debugPrint('Full URL: $url');
      debugPrint('Question ID: $questionId');
      debugPrint('Auth Token: ${authToken.substring(0, 10)}...');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint('=== Answer API Response Details ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Data Type: ${response.data.runtimeType}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is! Map) {
          debugPrint(
              'Error: Response data is not a Map. It is: ${response.data.runtimeType}');
          throw Exception('Invalid response format from server');
        }

        if (!response.data.containsKey('answers')) {
          debugPrint(
              'Error: Response data does not contain "answers" key. Keys present: ${response.data.keys.toList()}');
          throw Exception('Response missing answers data');
        }

        final List<dynamic> data = response.data['answers'];
        debugPrint('Number of answers received: ${data.length}');

        if (data.isEmpty) {
          debugPrint('No answers found for question $questionId');
          return [];
        }

        final answers = data.map((json) {
          debugPrint('Processing answer JSON: $json');
          try {
            // Ensure required fields are present
            if (!json.containsKey('answerid') ||
                !json.containsKey('userid') ||
                !json.containsKey('questionid') ||
                !json.containsKey('answer') ||
                !json.containsKey('username')) {
              debugPrint(
                  'Error: Answer JSON missing required fields. Available fields: ${json.keys.toList()}');
              throw Exception('Answer data missing required fields');
            }

            // Convert numeric IDs to strings if needed
            final processedJson = {
              ...json as Map<String, dynamic>,
              'answerid': json['answerid'].toString(),
              'userid': json['userid'].toString(),
              'questionid': json['questionid'].toString(),
            };

            return Answer.fromJson(processedJson);
          } catch (e) {
            debugPrint('Error processing answer JSON: $e');
            debugPrint('Problematic JSON: $json');
            rethrow;
          }
        }).toList();

        debugPrint('Successfully parsed ${answers.length} answers');
        return answers;
      } else {
        final errorMessage =
            response.data is Map && response.data.containsKey('message')
                ? response.data['message']
                : 'Failed to fetch answers (Status: ${response.statusCode})';
        debugPrint('Error response: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('=== DioException Details ===');
      debugPrint('Error Type: ${e.type}');
      debugPrint('Error Message: ${e.message}');
      if (e.response != null) {
        debugPrint('Error Response Status: ${e.response?.statusCode}');
        debugPrint('Error Response Data: ${e.response?.data}');
        debugPrint('Error Response Headers: ${e.response?.headers}');
      }
      if (e.error != null) {
        debugPrint('Error Object: ${e.error}');
      }
      throw Exception(e.response?.data['message'] ??
          'Failed to fetch answers: ${e.message}');
    } catch (e) {
      debugPrint('=== Unexpected Error Details ===');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');
      throw Exception('Failed to fetch answers: $e');
    }
  }

  Future<void> submitAnswer({
    required String questionId,
    required String content,
    required String authToken,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/answers',
        data: {
          'questionid': questionId,
          'answer': content,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
      );
      debugPrint(
          'Submit Answer API Response Status Code: ${response.statusCode}');
      debugPrint('Submit Answer API Response Data: ${response.data}');

      if (response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Failed to submit answer');
      }
    } on DioException catch (e) {
      debugPrint('Error submitting answer: ${e.message}');
      if (e.response != null) {
        debugPrint(
            'Error response data during submission: ${e.response?.data}');
      }
      throw Exception(e.response?.data['message'] ?? 'Failed to submit answer');
    }
  }

  Future<void> editAnswer({
    required String answerId,
    required String content,
    required String authToken,
  }) async {
    try {
      debugPrint('=== Edit Answer API Request Details ===');
      debugPrint('URL: $_baseUrl/answers/$answerId');
      debugPrint('Payload: {\'content\': \'$content\'}');
      debugPrint('Auth Token: ${authToken.substring(0, 10)}...');

      final response = await _dio.put(
        '$_baseUrl/answers/$answerId',
        data: {
          'content': content,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
      );

      debugPrint('=== Edit Answer API Response Details ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Data Type: ${response.data.runtimeType}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorMessage =
            response.data is Map && response.data.containsKey('message')
                ? response.data['message']
                : 'Failed to edit answer (Status: ${response.statusCode})';
        debugPrint('Error response from server (non-2xx): $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('=== DioException during Edit Answer ===');
      debugPrint('Error Type: ${e.type}');
      debugPrint('Error Message: ${e.message}');
      if (e.response != null) {
        debugPrint('Error Response Status: ${e.response?.statusCode}');
        debugPrint('Error Response Data: ${e.response?.data}');
        debugPrint('Error Response Headers: ${e.response?.headers}');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to edit answer: ${e.message}');
    } catch (e) {
      debugPrint('=== Unexpected Error during Edit Answer ===');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');
      throw Exception('Failed to edit answer: $e');
    }
  }

  Future<void> deleteAnswer({
    required String answerId,
    required String authToken,
  }) async {
    try {
      await _dio.delete(
        '$_baseUrl/answers/$answerId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete answer');
    }
  }
}
