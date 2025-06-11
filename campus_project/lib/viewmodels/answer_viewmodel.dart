import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/answer_model.dart';
import '../config/api_config.dart';

class AnswerViewModel extends ChangeNotifier {
  List<Answer> _answers = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  final String _baseUrl = ApiConfig.baseUrl;
  final String _authToken;

  AnswerViewModel({required String authToken}) : _authToken = authToken;

  List<Answer> get answers => _answers;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<void> fetchAnswers(String questionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Ensure questionId is a String for URI construction
      final uri = Uri.parse('$_baseUrl/answers/$questionId');
      if (kDebugMode) {
        print('Fetching answers from: $uri');
        print('Authorization Token: $_authToken');
      }
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (kDebugMode) {
        print('Fetch Answers Response Status Code: ${response.statusCode}');
        print('Fetch Answers Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (kDebugMode) {
          print('Decoded JSON data for answers: $data');
        }
        if (data.containsKey('answers') && data['answers'] is List) {
          _answers = (data['answers'] as List)
              .map((json) => Answer.fromJson({
                    ...json,
                    'created_at':
                        json['created_at'] ?? DateTime.now().toIso8601String(),
                    'updated_at':
                        json['updated_at'] ?? DateTime.now().toIso8601String(),
                  }))
              .toList();
          if (kDebugMode) {
            print('Successfully parsed ${_answers.length} answers.');
          }
        } else {
          if (kDebugMode) {
            print(
                "Error: Backend response missing 'answers' key or it's not a List.");
          }
          _answers = []; // Ensure answers list is empty if data is malformed
          _error = "Invalid data format from server."; // Set a specific error
        }
        _isLoading = false;
        notifyListeners();
      } else {
        // Handle non-200 status codes
        String errorMessage =
            "Failed to load answers: Status ${response.statusCode}";
        try {
          final errorData = json.decode(response.body);
          // Try to get a specific message from the backend
          if (errorData.containsKey('message') &&
              errorData['message'] is String) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('msg') &&
              errorData['msg'] is String) {
            errorMessage = errorData['msg'];
          }
        } catch (e) {
          // If JSON decoding fails, use the default message
          if (kDebugMode) {
            print('Error decoding backend error response: $e');
          }
        }
        _error = errorMessage;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching answers (catch block): $e');
      }
      _isLoading = false;
      _error = 'Failed to connect to server: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> submitAnswer(String questionId, String content) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl/answers/');
      if (kDebugMode) {
        print('Submitting answer to: $uri');
        print('Authorization Token: $_authToken');
        print(
            'Request Body: {"questionid": "$questionId", "answer": "$content"}');
      }

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'questionid': questionId, // Ensure this is a String
          'answer': content,
        }),
      );

      if (kDebugMode) {
        print('Submit Answer Response Status Code: ${response.statusCode}');
        print('Submit Answer Response Body: ${response.body}');
      }

      if (response.statusCode == 201) {
        // Successfully submitted, now refetch answers
        await fetchAnswers(questionId);
        _isSubmitting = false;
        notifyListeners();
      } else {
        _isSubmitting = false;
        String errorMessage =
            'Failed to submit answer: Status ${response.statusCode}';
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
          if (kDebugMode) {
            print('Error decoding backend error response: $e');
          }
        }
        _error = errorMessage;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting answer (catch block): $e');
      }
      _isSubmitting = false;
      _error = 'Failed to connect to server: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> editAnswer(String answerId, String newContent) async {
    _isSubmitting = true; // Use isSubmitting for edit operations as well
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl/answers/$answerId');
      if (kDebugMode) {
        print('Editing answer at: $uri');
        print('Authorization Token: $_authToken');
        print('Request Body: {"answer": "$newContent"}');
      }

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'answer': newContent,
        }),
      );

      if (kDebugMode) {
        print('Edit Answer Response Status Code: ${response.statusCode}');
        print('Edit Answer Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // After successful edit, refetch answers to update the UI
        // You might want to update a single answer in the list for better performance
        // For simplicity, refetching all answers for now.
        // await fetchAnswers(questionId); // You need questionId here if you want to refetch.
        // A more efficient way would be to update the specific answer in the _answers list
        final index =
            _answers.indexWhere((answer) => answer.answerId == answerId);
        if (index != -1) {
          _answers[index] = Answer(
            answerId: answerId,
            userId: _answers[index].userId,
            questionId: _answers[index].questionId,
            content: newContent,
            username: _answers[index].username,
            profession: _answers[index].profession,
          );
        }

        _isSubmitting = false;
        _error = null;
        notifyListeners();
      } else {
        _isSubmitting = false;
        String? backendError;
        try {
          final errorData = json.decode(response.body);
          backendError = errorData['message'] ?? errorData['msg'];
        } catch (e) {
          // ignore
        }
        _error = backendError ?? 'Failed to edit answer';
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error editing answer (catch block): $e');
      }
      _isSubmitting = false;
      _error = 'Failed to connect to server: ${e.toString()}';
      notifyListeners();
    }
  }
}
