import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:campus_project/screens/AnswerScreen.dart';
import 'package:campus_project/controllers/answer_controller.dart';
import 'package:campus_project/states/answer_state.dart';
import 'package:campus_project/models/answer_model.dart';

@GenerateMocks([AnswerController, AnswerActionController])
import 'answer_screen_test.mocks.dart';

void main() {
  const mockAuthToken = 'mock-auth-token';
  const mockQuestionId = 'test-question-123';
  const mockQuestionTitle = 'Test Question Title';

  late MockAnswerController mockAnswerController;
  late MockAnswerActionController mockAnswerActionController;

  setUp(() {
    mockAnswerController = MockAnswerController();
    mockAnswerActionController = MockAnswerActionController();

    // Stub addListener for AnswerController
    when(mockAnswerController.addListener(any,
            fireImmediately: anyNamed('fireImmediately')))
        .thenReturn(() => {});

    // Default stubbing for AnswerController
    when(mockAnswerController.setAuthToken(any)).thenReturn(null);
    when(mockAnswerController.fetchAnswers(any))
        .thenAnswer((_) async => const AnswerState.success([
              Answer(
                  answerId: '1',
                  content: 'First test answer',
                  userId: 'user1',
                  questionId: mockQuestionId,
                  username: 'john.doe',
                  firstName: 'John',
                  lastName: 'Doe',
                  profession: 'student'),
              Answer(
                  answerId: '2',
                  content: 'Second test answer',
                  userId: 'user2',
                  questionId: mockQuestionId,
                  username: 'jane.smith',
                  firstName: 'Jane',
                  lastName: 'Smith',
                  profession: 'professor'),
            ]));
    when(mockAnswerController.invalidateCache(any)).thenReturn(null);
    when(mockAnswerController.state).thenReturn(
        const AnswerState.initial()); // Explicitly set initial state

    // Stub addListener for AnswerActionController
    when(mockAnswerActionController.addListener(any,
            fireImmediately: anyNamed('fireImmediately')))
        .thenReturn(() => {});

    // Default stubbing for AnswerActionController
    when(mockAnswerActionController.setAuthToken(any)).thenReturn(null);
    when(mockAnswerActionController.submitAnswer(
            questionId: anyNamed('questionId'), content: anyNamed('content')))
        .thenAnswer((_) async => const AnswerActionState.success());
    when(mockAnswerActionController.editAnswer(
            answerId: anyNamed('answerId'), content: anyNamed('content')))
        .thenAnswer((_) async => const AnswerActionState.success());
    when(mockAnswerActionController.deleteAnswer(
            answerId: anyNamed('answerId')))
        .thenAnswer((_) async => const AnswerActionState.success());
    when(mockAnswerActionController.state).thenReturn(
        const AnswerActionState.initial()); // Explicitly set initial state
  });

  testWidgets('AnswerScreen displays question title and answer form',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          answerControllerProvider.overrideWith((ref) => mockAnswerController),
          answerActionProvider
              .overrideWith((ref) => mockAnswerActionController),
        ],
        child: MaterialApp(
          home: AnswersScreen(
            questionId: mockQuestionId,
            questionTitle: mockQuestionTitle,
            authToken: mockAuthToken,
          ),
        ),
      ),
    );

    // Initial pump and settle to allow initState to complete and fetchAnswers to run
    await tester.pumpAndSettle();

    // Verify that the question title is displayed
    expect(find.text(mockQuestionTitle), findsOneWidget);

    // Verify that the answer form is displayed
    expect(find.byType(TextFormField), findsOneWidget); // Answer text field
    expect(find.byType(ElevatedButton), findsOneWidget); // Submit button
  });

  testWidgets('AnswerScreen handles answer submission',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          answerControllerProvider.overrideWith((ref) => mockAnswerController),
          answerActionProvider
              .overrideWith((ref) => mockAnswerActionController),
        ],
        child: MaterialApp(
          home: AnswersScreen(
            questionId: mockQuestionId,
            questionTitle: mockQuestionTitle,
            authToken: mockAuthToken,
          ),
        ),
      ),
    );

    // Initial pump to allow initState to complete
    await tester.pumpAndSettle();

    // Enter answer text
    await tester.enterText(find.byType(TextFormField), 'This is a test answer');
    expect(find.text('This is a test answer'), findsOneWidget);

    // Tap the submit button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester
        .pumpAndSettle(); // Wait for the submission and snackbar to appear

    // Verify that submitAnswer was called
    verify(mockAnswerActionController.submitAnswer(
      questionId: mockQuestionId,
      content: 'This is a test answer',
    )).called(1);

    // Verify snackbar message
    expect(find.text('Answer submitted successfully'), findsOneWidget);

    // Verify that the text field is cleared after submission
    expect(find.text('This is a test answer'), findsNothing);
  });

  testWidgets('AnswerScreen shows validation error for empty answer',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          answerControllerProvider.overrideWith((ref) => mockAnswerController),
          answerActionProvider
              .overrideWith((ref) => mockAnswerActionController),
        ],
        child: MaterialApp(
          home: AnswersScreen(
            questionId: mockQuestionId,
            questionTitle: mockQuestionTitle,
            authToken: mockAuthToken,
          ),
        ),
      ),
    );

    // Initial pump to allow initState to complete
    await tester.pumpAndSettle();

    // Try to submit without entering any text
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester.pumpAndSettle(); // Wait for validation message to appear

    // Verify validation message
    expect(find.text('Please enter an answer'), findsOneWidget);
    verifyNever(mockAnswerActionController.submitAnswer(
      questionId: anyNamed('questionId'),
      content: anyNamed('content'),
    ));
  });

  testWidgets('AnswerScreen displays existing answers',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          answerControllerProvider.overrideWith((ref) => mockAnswerController),
          answerActionProvider
              .overrideWith((ref) => mockAnswerActionController),
        ],
        child: MaterialApp(
          home: AnswersScreen(
            questionId: mockQuestionId,
            questionTitle: mockQuestionTitle,
            authToken: mockAuthToken,
          ),
        ),
      ),
    );

    // Wait for answers to load (initState calls fetchAnswers)
    await tester.pumpAndSettle();

    // Verify that fetchAnswers was called
    verify(mockAnswerController.fetchAnswers(mockQuestionId)).called(1);

    // Verify that answers are displayed
    expect(find.text('First test answer'), findsOneWidget);
    expect(find.text('Second test answer'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Smith'), findsOneWidget);
  });
}
