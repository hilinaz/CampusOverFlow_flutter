import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:campus_project/controllers/question_controller.dart';
import 'package:campus_project/repositories/question_repository.dart';
import 'package:campus_project/states/question_state.dart';
import 'package:campus_project/models/question_model.dart';

@GenerateMocks([QuestionRepository])
import 'question_controller_test.mocks.dart';

void main() {
  late MockQuestionRepository mockRepository;
  late ProviderContainer container;
  late QuestionController controller;

  setUp(() {
    mockRepository = MockQuestionRepository();
    container = ProviderContainer(
      overrides: [
        questionRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    controller = container.read(questionControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('QuestionController State Management', () {
    test('Initial state is correct', () {
      expect(container.read(questionControllerProvider), isA<QuestionState>());
    });

    test('Setting auth token triggers fetch', () async {
      const mockToken = 'mock-token';
      final mockQuestions = [
        Question(
          questionId: '1',
          title: 'Test Question',
          description: 'Test Description',
          userId: 'user1',
          tag: 'general',
          username: 'testuser',
          profession: 'student',
        ),
      ];

      when(mockRepository.fetchQuestions(mockToken))
          .thenAnswer((_) async => mockQuestions);

      controller.setAuthToken(mockToken);
      await Future.delayed(Duration.zero);

      verify(mockRepository.fetchQuestions(mockToken)).called(1);
      final state = container.read(questionControllerProvider);
      expect(state, isA<QuestionState>());
      state.maybeWhen(
        success: (questions, _) => expect(questions, mockQuestions),
        orElse: () => fail('Expected success state'),
      );
    });

    test('Setting search query filters questions', () async {
      const mockToken = 'mock-token';
      final mockQuestions = [
        Question(
          questionId: '1',
          title: 'Test Question',
          description: 'Test Description',
          userId: 'user1',
          tag: 'general',
          username: 'testuser',
          profession: 'student',
        ),
        Question(
          questionId: '2',
          title: 'Another Question',
          description: 'Another Description',
          userId: 'user2',
          tag: 'technical',
          username: 'testuser2',
          profession: 'student',
        ),
      ];

      when(mockRepository.fetchQuestions(mockToken))
          .thenAnswer((_) async => mockQuestions);

      controller.setAuthToken(mockToken);
      await Future.delayed(Duration.zero);

      controller.setSearchQuery('Test');
      await Future.delayed(Duration.zero);

      final state = container.read(questionControllerProvider);
      expect(state, isA<QuestionState>());
      state.maybeWhen(
        success: (questions, _) => expect(questions.length, 1),
        orElse: () => fail('Expected success state'),
      );
    });

    test('Error state is set when fetch fails', () async {
      const mockToken = 'mock-token';
      when(mockRepository.fetchQuestions(mockToken))
          .thenThrow(Exception('Network error'));

      controller.setAuthToken(mockToken);
      await Future.delayed(Duration.zero);

      final state = container.read(questionControllerProvider);
      expect(state, isA<QuestionState>());
      state.maybeWhen(
        error: (message) => expect(message, 'Exception: Network error'),
        orElse: () => fail('Expected error state'),
      );
    });
  });

  group('QuestionActionController State Management', () {
    late QuestionActionController actionController;

    setUp(() {
      actionController = container.read(questionActionProvider.notifier);
    });

    test('Initial state is correct', () {
      expect(
        container.read(questionActionProvider),
        isA<QuestionActionState>(),
      );
    });

    test('Create question success flow', () async {
      const mockToken = 'mock-token';
      actionController.setAuthToken(mockToken);

      when(mockRepository.createQuestion(
        authToken: mockToken,
        title: 'Test Title',
        description: 'Test Description',
        tag: 'general',
      )).thenAnswer((_) async => {});

      await actionController.createQuestion(
        title: 'Test Title',
        description: 'Test Description',
        tag: 'general',
      );

      final state = container.read(questionActionProvider);
      expect(state, isA<QuestionActionState>());
      state.maybeWhen(
        success: () => expect(true, isTrue),
        orElse: () => fail('Expected success state'),
      );
    });

    test('Create question error flow', () async {
      const mockToken = 'mock-token';
      actionController.setAuthToken(mockToken);

      when(mockRepository.createQuestion(
        authToken: mockToken,
        title: 'Test Title',
        description: 'Test Description',
        tag: 'general',
      )).thenThrow(Exception('Creation failed'));

      await actionController.createQuestion(
        title: 'Test Title',
        description: 'Test Description',
        tag: 'general',
      );

      final state = container.read(questionActionProvider);
      expect(state, isA<QuestionActionState>());
      state.maybeWhen(
        error: (message) => expect(message, 'Exception: Creation failed'),
        orElse: () => fail('Expected error state'),
      );
    });

    test('Update question success flow', () async {
      const mockToken = 'mock-token';
      actionController.setAuthToken(mockToken);

      when(mockRepository.updateQuestion(
        authToken: mockToken,
        questionId: '1',
        title: 'Updated Title',
        description: 'Updated Description',
        tag: 'technical',
      )).thenAnswer((_) async => {});

      await actionController.updateQuestion(
        questionId: '1',
        title: 'Updated Title',
        description: 'Updated Description',
        tag: 'technical',
      );

      final state = container.read(questionActionProvider);
      expect(state, isA<QuestionActionState>());
      state.maybeWhen(
        success: () => expect(true, isTrue),
        orElse: () => fail('Expected success state'),
      );
    });

    test('Delete question success flow', () async {
      const mockToken = 'mock-token';
      actionController.setAuthToken(mockToken);

      when(mockRepository.deleteQuestion(mockToken, '1'))
          .thenAnswer((_) async => {});

      await actionController.deleteQuestion('1');

      final state = container.read(questionActionProvider);
      expect(state, isA<QuestionActionState>());
      state.maybeWhen(
        success: () => expect(true, isTrue),
        orElse: () => fail('Expected success state'),
      );
    });
  });
}
