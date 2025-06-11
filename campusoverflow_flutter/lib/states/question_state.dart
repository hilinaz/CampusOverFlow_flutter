import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/question_model.dart';

part 'question_state.freezed.dart';

@freezed
class QuestionState with _$QuestionState {
  const factory QuestionState.initial() = _Initial;
  const factory QuestionState.loading() = _Loading;
  const factory QuestionState.success({
    required List<Question> questions,
    required String searchQuery,
  }) = _Success;
  const factory QuestionState.error(String message) = _Error;
}

@freezed
abstract class QuestionActionState with _$QuestionActionState {
  const factory QuestionActionState.initial() = _ActionInitial;
  const factory QuestionActionState.loading() = _ActionLoading;
  const factory QuestionActionState.success() = _ActionSuccess;
  const factory QuestionActionState.error({required String message}) =
      _ActionError;
}
