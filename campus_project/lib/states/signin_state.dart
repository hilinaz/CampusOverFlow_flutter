import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_state.freezed.dart';

@freezed
abstract class SigninState with _$SigninState {
  const factory SigninState.initial() = _Initial;
  const factory SigninState.loading() = _Loading;
  const factory SigninState.success({
    required String authToken,
    required String userFullName,
    required String profession,
    required int roleId,
  }) = _Success;
  const factory SigninState.error({required String message}) = _Error;
}
