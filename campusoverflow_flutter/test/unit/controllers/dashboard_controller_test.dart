import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:campus_project/controllers/dashboard_controller.dart';
import 'package:campus_project/repositories/dashboard_repository.dart';
import 'package:campus_project/states/dashboard_state.dart';
import 'package:dio/dio.dart';

@GenerateMocks([DashboardRepository])
import 'dashboard_controller_test.mocks.dart';

void main() {
  late MockDashboardRepository mockRepository;
  late ProviderContainer container;
  late DashboardController controller;

  setUp(() {
    mockRepository = MockDashboardRepository();
    container = ProviderContainer(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    controller = container.read(dashboardControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('DashboardController State Management', () {
    test('Initial state is correct', () {
      expect(
          container.read(dashboardControllerProvider), isA<DashboardState>());
      expect(
        container.read(dashboardControllerProvider),
        const DashboardState.initial(),
      );
    });

    test('Setting auth token does not fetch stats immediately', () {
      controller.setAuthToken('mock-token');
      // Should still be initial state
      expect(container.read(dashboardControllerProvider),
          const DashboardState.initial());
    });

    test('Fetch dashboard stats success', () async {
      const mockToken = 'mock-token';
      final mockStats = {
        'totalUsers': 10,
        'totalQuestions': 5,
        'totalAnswers': 20,
      };
      controller.setAuthToken(mockToken);
      when(mockRepository.getDashboardStats(mockToken))
          .thenAnswer((_) async => mockStats);

      await controller.fetchDashboardStats();

      verify(mockRepository.getDashboardStats(mockToken)).called(1);
      final state = container.read(dashboardControllerProvider);
      expect(state, isA<DashboardState>());
      state.maybeWhen(
        success: (totalUsers, totalQuestions, totalAnswers) {
          expect(totalUsers, 10);
          expect(totalQuestions, 5);
          expect(totalAnswers, 20);
        },
        orElse: () => fail('Expected success state'),
      );
    });

    test('Fetch dashboard stats error', () async {
      const mockToken = 'mock-token';
      controller.setAuthToken(mockToken);
      when(mockRepository.getDashboardStats(mockToken))
          .thenThrow(Exception('Network error'));

      await controller.fetchDashboardStats();

      final state = container.read(dashboardControllerProvider);
      expect(state, isA<DashboardState>());
      state.maybeWhen(
        error: (message) => expect(message, contains('Network error')),
        orElse: () => fail('Expected error state'),
      );
    });

    test('Fetch dashboard stats with no auth token', () async {
      await controller.fetchDashboardStats();
      final state = container.read(dashboardControllerProvider);
      expect(state, isA<DashboardState>());
      state.maybeWhen(
        error: (message) =>
            expect(message, contains('Authentication token not set')),
        orElse: () => fail('Expected error state'),
      );
    });

    test('Uses cached stats if not expired', () async {
      const mockToken = 'mock-token';
      final mockStats = {
        'totalUsers': 10,
        'totalQuestions': 5,
        'totalAnswers': 20,
      };
      controller.setAuthToken(mockToken);
      when(mockRepository.getDashboardStats(mockToken))
          .thenAnswer((_) async => mockStats);

      // First fetch to cache the stats
      await controller.fetchDashboardStats();
      verify(mockRepository.getDashboardStats(mockToken)).called(1);
      final state1 = container.read(dashboardControllerProvider);
      expect(state1, isA<DashboardState>());
      // Second fetch should use cache
      await controller.fetchDashboardStats();
      // No additional call to repository
      verifyNever(mockRepository.getDashboardStats(mockToken));
      final state2 = container.read(dashboardControllerProvider);
      expect(state2, isA<DashboardState>());
      state2.maybeWhen(
        success: (totalUsers, totalQuestions, totalAnswers) {
          expect(totalUsers, 10);
          expect(totalQuestions, 5);
          expect(totalAnswers, 20);
        },
        orElse: () => fail('Expected success state'),
      );
    });
  });
}
