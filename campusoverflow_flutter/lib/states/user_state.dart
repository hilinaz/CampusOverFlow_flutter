import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/user_model.dart';

part 'user_state.freezed.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;
  const factory UserState.loading() = _Loading;
  const factory UserState.success({
    required List<User> users,
    required String searchQuery,
  }) = _Success;
  const factory UserState.error(String message) = _Error;
}
