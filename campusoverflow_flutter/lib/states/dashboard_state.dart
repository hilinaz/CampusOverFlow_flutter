import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_state.freezed.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = _Initial;
  const factory DashboardState.loading() = _Loading;
  const factory DashboardState.success({
    required int totalUsers,
    required int totalQuestions,
    required int totalAnswers,
  }) = _Success;
  const factory DashboardState.error(String message) = _Error;
}
