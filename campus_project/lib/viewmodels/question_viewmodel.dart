import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/question_model.dart';
import '../models/answer_model.dart';
import '../config/api_config.dart';
import 'package:flutter/material.dart';
// Removed user_model.dart import as it's not strictly necessary for this revised Question model

enum QuestionSortOption {
  newest,
  // Sorting options not implemented in backend but kept for future use
}

class QuestionViewModel extends ChangeNotifier {
  List<Question> _questions = [];
  bool _isLoading = true;
  String? _error;
  QuestionSortOption _currentSort = QuestionSortOption.newest;
  String _searchQuery = '';
  final String _baseUrl = ApiConfig.baseUrl;
  final String _authToken;

  String? _currentUserName; // Only tracking first name now

  QuestionViewModel({required String authToken}) : _authToken = authToken {
    _fetchCurrentUserDetails(); // Fetch user details on initialization
  }

  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  QuestionSortOption get currentSort => _currentSort;
  String get searchQuery => _searchQuery;

  String? get currentUserName => _currentUserName;

  Future<void> _fetchCurrentUserDetails() async {
    // This is a placeholder. In a real app, you would fetch this from your backend
    // or decode from the JWT if the information is available there.
    // For now, let's assume a static user for demonstration.
    _currentUserName = "Ruth"; // Replace with actual fetched first name
    notifyListeners();

    // Example of fetching user details from an API (uncomment and modify as needed)
    /*
    try {
      final uri = Uri.parse('$_baseUrl/user/profile'); // Replace with your user profile endpoint
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming your backend returns 'firstName' directly
        _currentUserName = data['firstName'] as String?;
      } else {
        if (kDebugMode) print('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching user profile: $e');
    }
    notifyListeners();
    */
  }

  Future<void> fetchQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl/question');
      debugPrint('Fetching questions from: $uri'); // Debugging print
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      debugPrint(
          'Response status code: ${response.statusCode}'); // Debugging print
      debugPrint('Response body: ${response.body}'); // Debugging print

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming 'allQuestion' is the key holding the list of questions
        _questions = (data['allQuestion'] as List)
            .map((json) => Question.fromJson(json))
            .toList();
        _isLoading = false;
        debugPrint(
            'Fetched ${_questions.length} questions.'); // Debugging print
      } else {
        _isLoading = false;
        _error = 'Failed to load questions: ${response.statusCode}';
        debugPrint('Error loading questions: ${_error}'); // Debugging print
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to connect to server';
      debugPrint('Error fetching questions: $e'); // Debugging print
    }
    notifyListeners();
  }

  Future<void> searchQuestions(String query) async {
    _searchQuery = query;
    _error = null; // Clear previous errors related to search

    if (query.isEmpty) {
      // If the search query is empty, refetch all questions
      await fetchQuestions();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl/question/search/$query');
      debugPrint('Searching questions from: $uri'); // Debugging print
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      debugPrint(
          'Search response status code: ${response.statusCode}'); // Debugging print
      debugPrint('Search response body: ${response.body}'); // Debugging print

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _questions = (data['allQuestion'] as List)
            .map((json) => Question.fromJson(json))
            .toList();
        _isLoading = false;
        debugPrint(
            'Fetched ${_questions.length} questions for search.'); // Debugging print
      } else {
        _isLoading = false;
        _error = 'Search failed: ${response.statusCode}';
        debugPrint('Search error: ${_error}'); // Debugging print
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to connect to server';
      debugPrint('Error searching questions: $e'); // Debugging print
    }
    notifyListeners();
  }

  Future<void> createQuestion(
      String title, String description, String tag) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/question'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'tag': tag,
        }),
      );

      if (response.statusCode == 201) {
        await fetchQuestions();
        debugPrint('Question created successfully.'); // Debugging print
      } else {
        _error = 'Failed to create question: ${response.statusCode}';
        debugPrint('Create question error: ${_error}'); // Debugging print
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to connect to server';
      debugPrint('Error creating question: $e'); // Debugging print
      notifyListeners();
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/question/$questionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        await fetchQuestions();
        debugPrint('Question deleted successfully.'); // Debugging print
      } else {
        _error = 'Failed to delete question: ${response.statusCode}';
        debugPrint('Delete question error: ${_error}'); // Debugging print
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to connect to server';
      debugPrint('Error deleting question: $e'); // Debugging print
      notifyListeners();
    }
  }

  Future<void> updateQuestion(
      String questionId, String title, String description, String tag) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/question/$questionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'tag': tag,
        }),
      );

      if (response.statusCode == 200) {
        await fetchQuestions(); // Refresh the list of questions
        debugPrint('Question updated successfully.'); // Debugging print
      } else {
        _error = 'Failed to update question: ${response.statusCode}';
        debugPrint('Update question error: ${_error}'); // Debugging print
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to connect to server';
      debugPrint('Error updating question: $e'); // Debugging print
      notifyListeners();
    }
  }

  Future<void> getQuestionCount() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/api/question/countQuestions'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(
            'Total Questions: ${data['totalQuestions']}'); // Debugging print
      } else {
        _error = 'Failed to get question count: ${response.statusCode}';
        debugPrint('Get question count error: ${_error}'); // Debugging print
      }
    } catch (e) {
      debugPrint('Error getting question count: $e'); // Debugging print
    }
  }
}
