import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:campus_project/controllers/signup_controller.dart';
import 'package:campus_project/repositories/signup_repository.dart';
import 'package:campus_project/models/user_model.dart';

@GenerateMocks([SignupRepository])
import 'signup_controller_test.mocks.dart';

void main() {
  late MockSignupRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockSignupRepository();
    container = ProviderContainer(
      overrides: [
        signupRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SignupController State Management', () {
    test('Initial state is AsyncData with null', () {
      final controller = container.read(signupControllerProvider.notifier);
      expect(controller.state, AsyncValue<User?>.data(null));
    });

    test('Signup success updates state with user data', () async {
      final expectedUser = User(
        id: 1,
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        profession: 'student',
        email: 'john@example.com',
        password: 'password123',
      );

      when(mockRepository.signup(any)).thenAnswer((_) async => expectedUser);

      final controller = container.read(signupControllerProvider.notifier);

      await controller.signup(
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        profession: 'student',
        email: 'john@example.com',
        password: 'password123',
      );

      expect(controller.state, AsyncValue<User?>.data(expectedUser));
      verify(mockRepository.signup(any)).called(1);
    });

    test('Signup with connection timeout shows appropriate error', () async {
      when(mockRepository.signup(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/register'),
          type: DioExceptionType.connectionTimeout,
          error:
              'Connection timed out. Please check your internet connection and try again.',
        ),
      );

      final controller = container.read(signupControllerProvider.notifier);

      await controller.signup(
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        profession: 'student',
        email: 'john@example.com',
        password: 'password123',
      );

      expect(
        controller.state,
        isA<AsyncError<User?>>().having(
          (error) => error.error.toString(),
          'error message',
          contains('Connection timed out'),
        ),
      );
    });

    test('Signup with email already exists shows appropriate error', () async {
      when(mockRepository.signup(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/register'),
          response: Response(
            requestOptions: RequestOptions(path: '/users/register'),
            statusCode: 409,
            data: {'msg': 'Email already exists'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final controller = container.read(signupControllerProvider.notifier);

      await controller.signup(
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        profession: 'student',
        email: 'john@example.com',
        password: 'password123',
      );

      expect(
        controller.state,
        isA<AsyncError<User?>>().having(
          (error) => (error.error as DioException).response?.data['msg'],
          'error message',
          contains('Email already exists'),
        ),
      );
    });

    test('Signup with network error shows appropriate error', () async {
      when(mockRepository.signup(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/register'),
          type: DioExceptionType.connectionError,
          error:
              'Unable to connect to the server. Please check your internet connection.',
        ),
      );

      final controller = container.read(signupControllerProvider.notifier);

      await controller.signup(
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        profession: 'student',
        email: 'john@example.com',
        password: 'password123',
      );

      expect(
        controller.state,
        isA<AsyncError<User?>>().having(
          (error) => error.error.toString(),
          'error message',
          contains('Unable to connect to the server'),
        ),
      );
    });

    test('Reset clears the state', () async {
      final controller = container.read(signupControllerProvider.notifier);

      // First set an error state
      when(mockRepository.signup(any)).thenThrow(Exception('Test error'));

      await controller.signup(
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        profession: 'student',
        email: 'john@example.com',
        password: 'password123',
      );

      expect(controller.state, isA<AsyncError>());

      // Then reset
      controller.reset();
      expect(controller.state, AsyncValue<User?>.data(null));
    });

    test('Loading state is set during signup', () async {
      // Create a completer to control the async flow
      final completer = Completer<User?>();

      when(mockRepository.signup(any)).thenAnswer((_) => completer.future);

      final controller = container.read(signupControllerProvider.notifier);

      // Start the signup process
      final signupFuture = controller.signup(
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        profession: 'student',
        email: 'john@example.com',
        password: 'password123',
      );

      // Verify loading state
      expect(controller.state, const AsyncValue<User?>.loading());

      // Complete the signup
      completer.complete(User(
        id: 1,
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        profession: 'student',
        email: 'john@example.com',
        password: 'password123',
      ));

      await signupFuture;
    });

    test('Signup with invalid data shows appropriate error', () async {
      when(mockRepository.signup(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/register'),
          response: Response(
            requestOptions: RequestOptions(path: '/users/register'),
            statusCode: 400,
            data: {'msg': 'Invalid input data'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final controller = container.read(signupControllerProvider.notifier);

      await controller.signup(
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        profession: 'student',
        email: 'invalid-email',
        password: '123', // Too short password
      );

      expect(
        controller.state,
        isA<AsyncError<User?>>().having(
          (error) => (error.error as DioException).response?.data['msg'],
          'error message',
          contains('Invalid input data'),
        ),
      );
    });

    test('Signup with server error shows appropriate error', () async {
      when(mockRepository.signup(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users/register'),
          response: Response(
            requestOptions: RequestOptions(path: '/users/register'),
            statusCode: 500,
            data: {'msg': 'Internal server error'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final controller = container.read(signupControllerProvider.notifier);

      await controller.signup(
        username: 'johndoe',
        firstName: 'John',
        lastName: 'Doe',
        profession: 'student',
        email: 'john@example.com',
        password: 'password123',
      );

      expect(
        controller.state,
        isA<AsyncError<User?>>().having(
          (error) => (error.error as DioException).response?.data['msg'],
          'error message',
          contains('Internal server error'),
        ),
      );
    });
  });
}
