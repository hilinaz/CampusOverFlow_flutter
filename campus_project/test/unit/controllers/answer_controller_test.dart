import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:campus_project/controllers/answer_controller.dart';
import 'package:campus_project/repositories/answer_repository.dart';
import 'package:campus_project/states/answer_state.dart';
import 'package:campus_project/models/answer_model.dart';

@GenerateMocks([AnswerRepository])
import 'answer_controller_test.mocks.dart';

void main() {
  late MockAnswerRepository mockRepository;
  late ProviderContainer container;
  late AnswerController controller;

  setUp(() {
    mockRepository = MockAnswerRepository();
    container = ProviderContainer(
      overrides: [
        answerRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    controller = container.read(answerControllerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('AnswerController State Management', () {
    test('Initial state is correct', () {
      expect(container.read(answerControllerProvider), isA<AnswerState>());
    });

    test('Setting auth token and fetching answers', () async {
      const mockToken = 'mock-token';
      const questionId = '1';
      final mockAnswers = [
        Answer(
          answerId: '1',
          questionId: questionId,
          userId: 'user1',
          content: 'Test Answer',
          username: 'testuser',
          profession: 'student',
          createdAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getAnswers(questionId, mockToken))
          .thenAnswer((_) async => mockAnswers);

      controller.setAuthToken(mockToken);
      await controller.fetchAnswers(questionId);

      verify(mockRepository.getAnswers(questionId, mockToken)).called(1);
      final state = container.read(answerControllerProvider);
      expect(state, isA<AnswerState>());
      state.maybeWhen(
        success: (answers) => expect(answers, mockAnswers),
        orElse: () => fail('Expected success state'),
      );
    });

    test('Error state is set when fetch fails', () async {
      const mockToken = 'mock-token';
      const questionId = '1';
      when(mockRepository.getAnswers(questionId, mockToken))
          .thenThrow(Exception('Network error'));

      controller.setAuthToken(mockToken);
      await controller.fetchAnswers(questionId);

      final state = container.read(answerControllerProvider);
      expect(state, isA<AnswerState>());
      state.maybeWhen(
        error: (message) => expect(message, 'Exception: Network error'),
        orElse: () => fail('Expected error state'),
      );
    });
  });

  group('AnswerActionController State Management', () {
    late AnswerActionController actionController;

    setUp(() {
      actionController = container.read(answerActionProvider.notifier);
    });

    test('Initial state is correct', () {
      expect(
        container.read(answerActionProvider),
        isA<AnswerActionState>(),
      );
    });

    test('Create answer success flow', () async {
      const mockToken = 'mock-token';
      const questionId = '1';
      actionController.setAuthToken(mockToken);

      when(mockRepository.submitAnswer(
        questionId: questionId,
        content: 'Test Answer',
        authToken: mockToken,
      )).thenAnswer((_) async => {});

      await actionController.submitAnswer(
        questionId: questionId,
        content: 'Test Answer',
      );

      final state = container.read(answerActionProvider);
      expect(state, isA<AnswerActionState>());
      state.maybeWhen(
        success: () => expect(true, isTrue),
        orElse: () => fail('Expected success state'),
      );
    });

    test('Create answer error flow', () async {
      const mockToken = 'mock-token';
      const questionId = '1';
      actionController.setAuthToken(mockToken);

      when(mockRepository.submitAnswer(
        questionId: questionId,
        content: 'Test Answer',
        authToken: mockToken,
      )).thenThrow(Exception('Creation failed'));

      await actionController.submitAnswer(
        questionId: questionId,
        content: 'Test Answer',
      );

      final state = container.read(answerActionProvider);
      expect(state, isA<AnswerActionState>());
      state.maybeWhen(
        error: (message) => expect(message, 'Exception: Creation failed'),
        orElse: () => fail('Expected error state'),
      );
    });

    test('Update answer success flow', () async {
      const mockToken = 'mock-token';
      const answerId = '1';
      actionController.setAuthToken(mockToken);

      when(mockRepository.editAnswer(
        answerId: answerId,
        content: 'Updated Answer',
        authToken: mockToken,
      )).thenAnswer((_) async => {});

      await actionController.editAnswer(
        answerId: answerId,
        content: 'Updated Answer',
      );

      final state = container.read(answerActionProvider);
      expect(state, isA<AnswerActionState>());
      state.maybeWhen(
        success: () => expect(true, isTrue),
        orElse: () => fail('Expected success state'),
      );
    });

    test('Delete answer success flow', () async {
      const mockToken = 'mock-token';
      const answerId = '1';
      actionController.setAuthToken(mockToken);

      when(mockRepository.deleteAnswer(
        answerId: answerId,
        authToken: mockToken,
      )).thenAnswer((_) async => {});

      await actionController.deleteAnswer(answerId: answerId);

      final state = container.read(answerActionProvider);
      expect(state, isA<AnswerActionState>());
      state.maybeWhen(
        success: () => expect(true, isTrue),
        orElse: () => fail('Expected success state'),
      );
    });
  });
}
