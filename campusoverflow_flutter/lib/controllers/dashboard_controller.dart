import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/dashboard_repository.dart';
import '../states/dashboard_state.dart';
import 'package:flutter/foundation.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController(ref.watch(dashboardRepositoryProvider));
});

class DashboardController extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  String? _authToken;
  Map<String, int>? _cachedStats;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  DashboardController(this._repository) : super(const DashboardState.initial());

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<void> fetchDashboardStats() async {
    if (_authToken == null) {
      debugPrint(
          'DashboardController: Auth token is null. Cannot fetch stats.');
      state = const DashboardState.error('Authentication token not set');
      return;
    }

    // Return cached data if it's still valid
    if (_cachedStats != null && _lastFetchTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastFetchTime!) < _cacheDuration) {
        debugPrint('DashboardController: Returning cached stats.');
        state = DashboardState.success(
          totalUsers: _cachedStats!['totalUsers']!,
          totalQuestions: _cachedStats!['totalQuestions']!,
          totalAnswers: _cachedStats!['totalAnswers']!,
        );
        return;
      }
    }

    debugPrint('DashboardController: Fetching new dashboard stats...');
    state = const DashboardState.loading();
    try {
      final startTime = DateTime.now();
      final stats = await _repository.getDashboardStats(_authToken!);
      final endTime = DateTime.now();
      debugPrint(
          'DashboardController: API call completed in ${endTime.difference(startTime).inMilliseconds}ms.');

      _cachedStats = stats;
      _lastFetchTime = DateTime.now();
      state = DashboardState.success(
        totalUsers: stats['totalUsers']!,
        totalQuestions: stats['totalQuestions']!,
        totalAnswers: stats['totalAnswers']!,
      );
      debugPrint('DashboardController: State updated to success.');
    } catch (e) {
      debugPrint('DashboardController: Error fetching stats: $e');
      state = DashboardState.error(e.toString());
    }
  }
}
