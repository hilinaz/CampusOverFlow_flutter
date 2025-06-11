import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/answer_model.dart';

part 'answer_state.freezed.dart';

@freezed
class AnswerState with _$AnswerState {
  const factory AnswerState.initial() = _Initial;
  const factory AnswerState.loading() = _Loading;
  const factory AnswerState.success(List<Answer> answers) = _Success;
  const factory AnswerState.error(String message) = _Error;
}

@freezed
class AnswerActionState with _$AnswerActionState {
  const factory AnswerActionState.initial() = _ActionInitial;
  const factory AnswerActionState.loading() = _ActionLoading;
  const factory AnswerActionState.success() = _ActionSuccess;
  const factory AnswerActionState.error(String message) = _ActionError;
}
