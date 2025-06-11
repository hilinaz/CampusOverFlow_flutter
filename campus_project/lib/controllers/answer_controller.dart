import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/answer_repository.dart';
import '../states/answer_state.dart';
import 'package:flutter/foundation.dart';
import '../models/answer_model.dart';

final answerRepositoryProvider = Provider<AnswerRepository>((ref) {
  return AnswerRepository();
});

final answerControllerProvider =
    StateNotifierProvider<AnswerController, AnswerState>((ref) {
  return AnswerController(ref.watch(answerRepositoryProvider));
});

final answerActionProvider =
    StateNotifierProvider<AnswerActionController, AnswerActionState>((ref) {
  return AnswerActionController(ref.watch(answerRepositoryProvider), ref);
});

class AnswerController extends StateNotifier<AnswerState> {
  final AnswerRepository _repository;
  String? _authToken;
  final Map<String, List<Answer>> _cachedAnswers = {};
  final Map<String, DateTime> _lastFetchTime = {};
  static const _cacheDuration = Duration(minutes: 5);

  AnswerController(this._repository) : super(const AnswerState.initial());

  void setAuthToken(String token) {
    _authToken = token;
  }

  void invalidateCache(String questionId) {
    _cachedAnswers.remove(questionId);
    _lastFetchTime.remove(questionId);
    debugPrint('AnswerController: Cache invalidated for question $questionId.');
  }

  Future<void> fetchAnswers(String questionId) async {
    if (_authToken == null) {
      debugPrint('AnswerController: Authentication token not set.');
      state = const AnswerState.error('Authentication token not set');
      return;
    }

    // Check cache first
    if (_cachedAnswers.containsKey(questionId) &&
        _lastFetchTime.containsKey(questionId)) {
      final now = DateTime.now();
      if (now.difference(_lastFetchTime[questionId]!) < _cacheDuration) {
        debugPrint(
            'AnswerController: Returning cached answers for question $questionId.');
        state = AnswerState.success(List.from(_cachedAnswers[questionId]!));
        return;
      }
    }

    debugPrint(
        'AnswerController: Fetching new answers for question $questionId...');
    state = const AnswerState.loading();
    try {
      final answers = await _repository.getAnswers(questionId, _authToken!);
      debugPrint('AnswerController: Fetched ${answers.length} answers.');
      _cachedAnswers[questionId] = answers; // Cache the fetched answers
      _lastFetchTime[questionId] = DateTime.now(); // Record fetch time
      state = AnswerState.success(List.from(answers));
    } catch (e) {
      debugPrint('AnswerController: Error fetching answers: $e');
      state = AnswerState.error(e.toString());
    }
  }
}

class AnswerActionController extends StateNotifier<AnswerActionState> {
  final AnswerRepository _repository;
  String? _authToken;
  final Ref _ref;

  AnswerActionController(this._repository, this._ref)
      : super(const AnswerActionState.initial());

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<void> submitAnswer({
    required String questionId,
    required String content,
  }) async {
    if (_authToken == null) {
      state = const AnswerActionState.error('Authentication token not set');
      return;
    }

    state = const AnswerActionState.loading();
    try {
      await _repository.submitAnswer(
        questionId: questionId,
        content: content,
        authToken: _authToken!,
      );
      state = const AnswerActionState.success();
    } catch (e) {
      state = AnswerActionState.error(e.toString());
    }
  }

  Future<void> editAnswer({
    required String answerId,
    required String content,
  }) async {
    if (_authToken == null) {
      state = const AnswerActionState.error('Authentication token not set');
      return;
    }

    state = const AnswerActionState.loading();
    try {
      await _repository.editAnswer(
        answerId: answerId,
        content: content,
        authToken: _authToken!,
      );
      state = const AnswerActionState.success();
    } catch (e) {
      state = AnswerActionState.error(e.toString());
    }
  }

  Future<void> deleteAnswer({
    required String answerId,
  }) async {
    if (_authToken == null) {
      state = const AnswerActionState.error('Authentication token not set');
      return;
    }

    state = const AnswerActionState.loading();
    try {
      await _repository.deleteAnswer(
        answerId: answerId,
        authToken: _authToken!,
      );
      state = const AnswerActionState.success();
    } catch (e) {
      state = AnswerActionState.error(e.toString());
    }
  }
}
