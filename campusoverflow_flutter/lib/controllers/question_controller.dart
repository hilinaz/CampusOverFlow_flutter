import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../repositories/question_repository.dart';
import '../states/question_state.dart';
import '../models/question_model.dart';

final questionRepositoryProvider =
    Provider<QuestionRepository>((ref) => QuestionRepository());

class QuestionController extends StateNotifier<QuestionState> {
  final QuestionRepository _repository;
  String? _authToken;
  String _searchQuery = '';

  QuestionController(this._repository) : super(const QuestionState.initial());

  void setAuthToken(String token) {
    debugPrint('Setting auth token in QuestionController');
    _authToken = token;
    // Fetch questions immediately when auth token is set
    fetchQuestions();
  }

  void setSearchQuery(String query) {
    debugPrint('Setting search query: $query');
    _searchQuery = query;
    state = state.when(
      initial: () => state,
      loading: () => state,
      success: (questions, _) => QuestionState.success(
        questions: _filterQuestions(questions, query),
        searchQuery: query,
      ),
      error: (_) => state,
    );
  }

  Future<void> fetchQuestions() async {
    if (_authToken == null) {
      debugPrint(
          'QuestionController: Cannot fetch questions: auth token is null');
      return;
    }

    debugPrint('QuestionController: Fetching questions...');
    state = const QuestionState.loading();

    try {
      final questions = await _repository.fetchQuestions(_authToken!);
      debugPrint(
          'QuestionController: Successfully fetched ${questions.length} questions');
      state = QuestionState.success(
        questions: _filterQuestions(questions, _searchQuery),
        searchQuery: _searchQuery,
      );
    } catch (e) {
      debugPrint('QuestionController: Error fetching questions: $e');
      state = QuestionState.error(e.toString());
    }
  }

  Future<void> searchQuestions(String query) async {
    if (_authToken == null) {
      debugPrint('Cannot search questions: auth token is null');
      return;
    }

    debugPrint('Searching questions with query: $query');
    state = const QuestionState.loading();

    try {
      final questions = await _repository.searchQuestions(_authToken!, query);
      debugPrint('Found ${questions.length} questions for query: $query');
      state = QuestionState.success(
        questions: questions,
        searchQuery: query,
      );
    } catch (e) {
      debugPrint('Error searching questions: $e');
      state = QuestionState.error(e.toString());
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    if (_authToken == null) {
      debugPrint('Cannot delete question: auth token is null');
      return;
    }

    debugPrint('Deleting question: $questionId');
    state = const QuestionState.loading();

    try {
      await _repository.deleteQuestion(_authToken!, questionId);
      debugPrint('Successfully deleted question: $questionId');
      await fetchQuestions();
    } catch (e) {
      debugPrint('Error deleting question: $e');
      state = QuestionState.error(e.toString());
    }
  }

  List<Question> _filterQuestions(List<Question> questions, String query) {
    if (query.isEmpty) return questions;
    final lowerQuery = query.toLowerCase();
    return questions.where((question) {
      final title = question.title.toLowerCase();
      final description = question.description.toLowerCase();
      return title.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();
  }
}

final questionControllerProvider =
    StateNotifierProvider<QuestionController, QuestionState>((ref) {
  final repo = ref.watch(questionRepositoryProvider);
  return QuestionController(repo);
});

final questionActionProvider =
    StateNotifierProvider<QuestionActionController, QuestionActionState>((ref) {
  final repository = ref.watch(questionRepositoryProvider);
  return QuestionActionController(repository);
});

class QuestionActionController extends StateNotifier<QuestionActionState> {
  final QuestionRepository _repository;
  String? _authToken;

  QuestionActionController(this._repository)
      : super(const QuestionActionState.initial());

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<void> createQuestion({
    required String title,
    required String description,
    required String tag,
  }) async {
    if (_authToken == null) {
      state = const QuestionActionState.error(
          message: 'Authentication token is missing');
      debugPrint(
          'QuestionActionController: Error creating question - Auth token is null.');
      return;
    }

    state = const QuestionActionState.loading();

    try {
      debugPrint(
          'QuestionActionController: Calling repository.createQuestion.');
      await _repository.createQuestion(
        authToken: _authToken!,
        title: title,
        description: description,
        tag: tag,
      );
      debugPrint('QuestionActionController: Question created successfully.');
      state = const QuestionActionState.success();
    } catch (e) {
      debugPrint(
          'QuestionActionController: Caught error in createQuestion: \$e');
      String errorMessage = 'Failed to create question.';
      if (e is DioException) {
        debugPrint('DioException in createQuestion: ${e.message}');
        debugPrint('DioException response data: ${e.response?.data}');
        errorMessage = e.response?.data['message'] ?? e.message ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }
      state = QuestionActionState.error(message: errorMessage);
      debugPrint(
          'QuestionActionController: State set to ERROR: \$errorMessage');
    }
  }

  Future<void> updateQuestion({
    required String questionId,
    required String title,
    required String description,
    required String tag,
  }) async {
    if (_authToken == null) {
      state =
          QuestionActionState.error(message: 'Authentication token is missing');
      return;
    }

    state = const QuestionActionState.loading();

    try {
      await _repository.updateQuestion(
        authToken: _authToken!,
        questionId: questionId,
        title: title,
        description: description,
        tag: tag,
      );
      state = const QuestionActionState.success();
    } catch (e) {
      state = QuestionActionState.error(message: e.toString());
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    state = const QuestionActionState.loading();

    try {
      await _repository.deleteQuestion(_authToken!, questionId);
      state = const QuestionActionState.success();
    } catch (e) {
      state = QuestionActionState.error(message: e.toString());
    }
  }
}
