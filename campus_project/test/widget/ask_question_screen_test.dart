import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_project/screens/AskQuestionScreen.dart';
import 'package:campus_project/controllers/question_controller.dart'; // Ensure this path is correct
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// IMPORTANT: Generate mocks by running:
// flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  QuestionController,
  QuestionActionController,
])
import 'ask_question_screen_test.mocks.dart'; // This file will be generated

void main() {
  const mockAuthToken = 'mock-auth-token';

  // Declare mock instances
  late MockQuestionController mockQuestionController;
  late MockQuestionActionController mockQuestionActionController;

  setUp(() {
    // Initialize mock instances before each test
    mockQuestionController = MockQuestionController();
    mockQuestionActionController = MockQuestionActionController();

    // --- Configure default mock behavior for QuestionController ---
    // Prevent real network calls for `fetchQuestions`
    when(mockQuestionController.fetchQuestions()).thenAnswer((_) async => []);
    // Mock `setAuthToken` if it's called
    when(mockQuestionController.setAuthToken(any)).thenReturn(null);

    // --- Configure default mock behavior for QuestionActionController ---
    // Mock `setAuthToken` if it's called
    when(mockQuestionActionController.setAuthToken(any)).thenReturn(null);

    // Simulate a successful question creation.
    // Ensure this matches the actual return type of your `createQuestion` method.
    // If your StateNotifier changes state, you might need to simulate that directly here
    // for the `actionState.when` block in your screen to be triggered.
    when(mockQuestionActionController.createQuestion(
      title: anyNamed('title'),
      description: anyNamed('description'),
      tag: anyNamed('tag'),
    )).thenAnswer((_) async {
      // If your `QuestionActionController` is a `StateNotifier`, you'd typically
      // mock a state emission like this:
      // verify(mockQuestionActionController.state = QuestionActionState.success());
      // For this example, assuming `createQuestion` returns `Future<void>`.
      return Future.value(); // Returns a completed Future<void>
    });
  });

  // --- Test 1: AskQuestionScreen shows question form and handles input ---
  testWidgets('AskQuestionScreen shows question form and handles input',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the real Riverpod providers with your mock instances
          questionControllerProvider
              .overrideWith((ref) => mockQuestionController),
          questionActionProvider
              .overrideWith((ref) => mockQuestionActionController),
        ],
        child: MaterialApp(
          home: AskQuestionScreen(
            authToken: mockAuthToken,
            onQuestionCreated: () {},
          ),
        ),
      ),
    );
    // Crucial: Wait for all initial rendering and any async operations (like initState)
    await tester.pumpAndSettle();

    // Verify that the form is displayed
    expect(find.text('Ask your Question'), findsOneWidget);
    expect(find.byType(TextField),
        findsNWidgets(2)); // Title and description fields
    expect(
        find.byType(DropdownButtonFormField), findsOneWidget); // Tag dropdown
    expect(find.byType(ElevatedButton), findsOneWidget); // Post button

    // Enter title using its ValueKey
    expect(find.byKey(const ValueKey('title_field')), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('title_field')), 'Test Question Title');
    expect(find.text('Test Question Title'), findsOneWidget);

    // Enter description using its ValueKey
    expect(find.byKey(const ValueKey('description_field')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('description_field')),
        'This is a test question description');
    expect(find.text('This is a test question description'), findsOneWidget);

    // Select tag
    await tester.tap(find.byType(DropdownButtonFormField));
    await tester.pumpAndSettle(); // Wait for the dropdown overlay to appear
    await tester
        .tap(find.text('Technical').last); // Select the 'Technical' option
    await tester.pumpAndSettle(); // Wait for the dropdown to close

    // Verify the submit button is enabled
    final postButton = find.widgetWithText(ElevatedButton, 'Post');
    expect(postButton, findsOneWidget);
    // Check if the button is enabled (assuming it's enabled by default if validation passes)
    expect(tester.widget<ElevatedButton>(postButton).enabled, isTrue);
  });

  // --- Test 2: AskQuestionScreen shows validation errors for empty fields ---
  testWidgets('AskQuestionScreen shows validation errors for empty fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionControllerProvider
              .overrideWith((ref) => mockQuestionController),
          questionActionProvider
              .overrideWith((ref) => mockQuestionActionController),
        ],
        child: MaterialApp(
          home: AskQuestionScreen(
            authToken: mockAuthToken,
            onQuestionCreated: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(); // Wait for initial rendering

    // Try to submit without entering any data
    await tester.tap(find.widgetWithText(ElevatedButton, 'Post'));
    await tester
        .pumpAndSettle(); // Wait for validation messages (SnackBar) to appear

    // Verify validation messages (SnackBars)
    // The message is "Please enter both title and description." in a single SnackBar
    expect(
        find.text('Please enter both title and description.'), findsOneWidget);
  });

  // --- Test 3: AskQuestionScreen handles question creation callback ---
  testWidgets('AskQuestionScreen handles question creation callback',
      (WidgetTester tester) async {
    bool callbackCalled = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override your actual providers with the mock instances
          questionControllerProvider
              .overrideWith((ref) => mockQuestionController),
          questionActionProvider
              .overrideWith((ref) => mockQuestionActionController),
        ],
        child: MaterialApp(
          home: AskQuestionScreen(
            authToken: mockAuthToken,
            onQuestionCreated: () {
              callbackCalled = true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(); // Wait for initial rendering

    // Fill in the form
    await tester.enterText(
        find.byKey(const ValueKey('title_field')), 'Test Question'); // Use Key
    await tester.enterText(find.byKey(const ValueKey('description_field')),
        'Test Description'); // Use Key

    await tester.tap(find.byType(DropdownButtonFormField));
    await tester.pumpAndSettle();
    await tester
        .tap(find.text('General').last); // Assuming 'General' option exists
    await tester.pumpAndSettle();

    // Submit the form
    await tester.tap(find.widgetWithText(ElevatedButton, 'Post'));
    await tester
        .pumpAndSettle(); // Wait for the _postQuestion to complete and callback/navigation to occur

    // Verify callback was called
    expect(callbackCalled, isTrue);

    // Verify the mock interaction: ensure createQuestion was called with correct arguments
    verify(mockQuestionActionController.createQuestion(
      title: 'Test Question',
      description: 'Test Description',
      tag: 'General',
    )).called(1);

    // Verify SnackBar message for success
    expect(find.text('Question posted successfully!'), findsOneWidget);

    // To verify navigation to QuestionsScreen, you would typically use a
    // `NavigatorObserver` in a real-world scenario.
  });
}
