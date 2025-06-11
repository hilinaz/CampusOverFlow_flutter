import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_state.freezed.dart';

@freezed
abstract class SignupState with _$SignupState {
  const factory SignupState.initial() = _Initial;
  const factory SignupState.loading() = _Loading;
  const factory SignupState.success(
      {required String authToken, required String userFullName}) = _Success;
  const factory SignupState.error({required String message}) = _Error;
}
