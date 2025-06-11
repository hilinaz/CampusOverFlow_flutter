import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:campus_project/controllers/user_controller.dart';
import 'package:campus_project/repositories/user_repository.dart';
import 'package:campus_project/states/user_state.dart';
import 'package:campus_project/models/user_model.dart';

@GenerateMocks([UserRepository])
import 'user_controller_test.mocks.dart';

void main() {
  late MockUserRepository mockRepository;
  late ProviderContainer container;
  late UserController controller;

  setUp(() {
    mockRepository = MockUserRepository();
    container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    controller = container.read(userControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('UserController State Management', () {
    test('Initial state is correct', () {
      expect(container.read(userControllerProvider), isA<UserState>());
      expect(container.read(userControllerProvider), const UserState.initial());
    });

    test('Setting auth token does not fetch users immediately', () async {
      const mockToken = 'mock-token';
      when(mockRepository.fetchUsers(mockToken)).thenAnswer((_) async => []);
      controller.setAuthToken(mockToken);
      expect(container.read(userControllerProvider), const UserState.loading());
    });

    test('Fetch users success', () async {
      const mockToken = 'mock-token';
      final mockUsers = [
        User(
            id: 1,
            firstName: 'John',
            lastName: 'Doe',
            profession: 'student',
            username: 'johndoe'),
        User(
            id: 2,
            firstName: 'Jane',
            lastName: 'Smith',
            profession: 'professor',
            username: 'janesmith'),
      ];
      controller.setAuthToken(mockToken);
      when(mockRepository.fetchUsers(mockToken))
          .thenAnswer((_) async => mockUsers);

      await controller.fetchUsers();

      verify(mockRepository.fetchUsers(mockToken)).called(2);
      final state = container.read(userControllerProvider);
      expect(state, isA<UserState>());
      state.maybeWhen(
        success: (users, _) => expect(users, mockUsers),
        orElse: () => fail('Expected success state'),
      );
    });

    test('Fetch users error', () async {
      const mockToken = 'mock-token';
      controller.setAuthToken(mockToken);
      when(mockRepository.fetchUsers(mockToken))
          .thenThrow(Exception('Network error'));

      await controller.fetchUsers();

      final state = container.read(userControllerProvider);
      expect(state, isA<UserState>());
      state.maybeWhen(
        error: (message) => expect(message, contains('Network error')),
        orElse: () => fail('Expected error state'),
      );
    });

    test('Fetch users with no auth token', () async {
      await controller.fetchUsers();
      final state = container.read(userControllerProvider);
      expect(state, const UserState.initial());
    });

    test('Search query filters users', () async {
      const mockToken = 'mock-token';
      final mockUsers = [
        User(
            id: 1,
            firstName: 'John',
            lastName: 'Doe',
            profession: 'student',
            username: 'johndoe'),
        User(
            id: 2,
            firstName: 'Jane',
            lastName: 'Smith',
            profession: 'professor',
            username: 'janesmith'),
      ];
      controller.setAuthToken(mockToken);
      when(mockRepository.fetchUsers(mockToken))
          .thenAnswer((_) async => mockUsers);

      await controller.fetchUsers();
      verify(mockRepository.fetchUsers(mockToken)).called(2);

      reset(mockRepository);
      when(mockRepository.fetchUsers(mockToken))
          .thenAnswer((_) async => mockUsers);

      controller.setSearchQuery('John');
      await controller.fetchUsers();
      verify(mockRepository.fetchUsers(mockToken)).called(1);
      final state = container.read(userControllerProvider);
      expect(state, isA<UserState>());
      state.maybeWhen(
        success: (users, _) => expect(users.length, 1),
        orElse: () => fail('Expected success state'),
      );
    });

    test('Uses cached users if not expired', () async {
      const mockToken = 'mock-token';
      final mockUsers = [
        User(
            id: 1,
            firstName: 'John',
            lastName: 'Doe',
            profession: 'student',
            username: 'johndoe'),
        User(
            id: 2,
            firstName: 'Jane',
            lastName: 'Smith',
            profession: 'professor',
            username: 'janesmith'),
      ];
      controller.setAuthToken(mockToken);
      when(mockRepository.fetchUsers(mockToken))
          .thenAnswer((_) async => mockUsers);

      await controller.fetchUsers();
      verify(mockRepository.fetchUsers(mockToken)).called(2);

      reset(mockRepository);
      when(mockRepository.fetchUsers(mockToken))
          .thenAnswer((_) async => mockUsers);

      await controller.fetchUsers();
      verifyNever(mockRepository.fetchUsers(mockToken));
      final state = container.read(userControllerProvider);
      expect(state, isA<UserState>());
      state.maybeWhen(
        success: (users, _) => expect(users, mockUsers),
        orElse: () => fail('Expected success state'),
      );
    });
  });
}
