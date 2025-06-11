import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';
import 'package:campus_project/controllers/signin_controller.dart';
import 'package:campus_project/repositories/signin_repository.dart';
import 'package:campus_project/states/signin_state.dart';
import 'package:dio/dio.dart';

@GenerateMocks([SigninRepository])
import 'signin_controller_test.mocks.dart';

void main() {
  late MockSigninRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockSigninRepository();
    container = ProviderContainer(
      overrides: [
        signinRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SigninController State Management', () {
    test('Initial state is AsyncData with null', () {
      final controller = container.read(signinControllerProvider.notifier);
      expect(controller.state, AsyncValue<Map<String, dynamic>?>.data(null));
    });

    test('Signin success updates state with user data', () async {
      final expectedData = {
        'token': 'test_token',
        'roleId': 1,
        'firstname': 'John',
        'lastname': 'Doe',
        'profession': 'student',
      };

      when(mockRepository.signin(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => expectedData);

      final controller = container.read(signinControllerProvider.notifier);

      await controller.signin(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(controller.state,
          AsyncValue<Map<String, dynamic>?>.data(expectedData));
      verify(mockRepository.signin(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('Signin with connection timeout shows appropriate error', () async {
      when(mockRepository.signin(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/login'),
          type: DioExceptionType.connectionTimeout,
          error:
              'Connection timed out. Please check your internet connection and try again.',
        ),
      );

      final controller = container.read(signinControllerProvider.notifier);

      await controller.signin(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(
        controller.state,
        isA<AsyncError<Map<String, dynamic>?>>().having(
          (error) => error.error.toString(),
          'error message',
          contains('Connection timed out'),
        ),
      );
    });

    test('Signin with invalid credentials shows appropriate error', () async {
      when(mockRepository.signin(
        email: 'test@example.com',
        password: 'wrong_password',
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/users/login'),
            statusCode: 401,
            data: {'msg': 'Invalid email or password'},
          ),
          type: DioExceptionType.badResponse,
          error: 'Invalid email or password',
        ),
      );

      final controller = container.read(signinControllerProvider.notifier);

      await controller.signin(
        email: 'test@example.com',
        password: 'wrong_password',
      );

      expect(
        controller.state,
        isA<AsyncError<Map<String, dynamic>?>>().having(
          (error) => error.error.toString(),
          'error message',
          contains('Invalid email or password'),
        ),
      );
    });

    test('Signin with network error shows appropriate error', () async {
      when(mockRepository.signin(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/login'),
          type: DioExceptionType.connectionError,
          error:
              'Unable to connect to the server. Please check your internet connection.',
        ),
      );

      final controller = container.read(signinControllerProvider.notifier);

      await controller.signin(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(
        controller.state,
        isA<AsyncError<Map<String, dynamic>?>>().having(
          (error) => error.error.toString(),
          'error message',
          contains('Unable to connect to the server'),
        ),
      );
    });

    test('Reset clears the state', () async {
      final controller = container.read(signinControllerProvider.notifier);

      // First set an error state
      when(mockRepository.signin(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(Exception('Test error'));

      await controller.signin(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(controller.state, isA<AsyncError<Map<String, dynamic>?>>());

      // Then reset
      controller.reset();
      expect(controller.state, AsyncValue<Map<String, dynamic>?>.data(null));
    });

    test('Loading state is set during signin', () async {
      // Create a completer to control the async flow
      final completer = Completer<Map<String, dynamic>>();

      when(mockRepository.signin(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) => completer.future);

      final controller = container.read(signinControllerProvider.notifier);

      // Start the signin process
      final signinFuture = controller.signin(
        email: 'test@example.com',
        password: 'password123',
      );

      // Verify loading state
      expect(
          controller.state, const AsyncValue<Map<String, dynamic>?>.loading());

      // Complete the signin
      completer.complete({
        'token': 'test_token',
        'roleId': 1,
        'firstname': 'John',
        'lastname': 'Doe',
        'profession': 'student',
      });

      await signinFuture;
    });
  });
}
