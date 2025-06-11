import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_project/main.dart' as app;
import 'package:campus_project/screens/SignInScreen.dart';
import 'package:campus_project/screens/QuestionsScreen.dart';
import 'package:campus_project/screens/AskQuestionScreen.dart';
import 'package:campus_project/screens/AnswerScreen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Complete user flow: sign in, ask question, and answer',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Verify we're on the questions screen
      expect(find.byType(QuestionsScreen), findsOneWidget);

      // Create a new question
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();

      // Fill in the question form
      await tester.enterText(find.widgetWithText(TextFormField, 'Title'),
          'Integration Test Question');
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'),
          'This is a question created during integration testing');
      await tester.tap(find.byType(DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Technical').last);
      await tester.pumpAndSettle();

      // Submit the question
      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
      await tester.pumpAndSettle();

      // Verify we're back on the questions screen
      expect(find.byType(QuestionsScreen), findsOneWidget);

      // Find and tap on our new question
      await tester.tap(find.text('Integration Test Question'));
      await tester.pumpAndSettle();

      // Verify we're on the answers screen
      expect(find.byType(AnswersScreen), findsOneWidget);

      // Add an answer
      await tester.enterText(
          find.byType(TextFormField), 'This is an integration test answer');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
      await tester.pumpAndSettle();

      // Verify our answer is displayed
      expect(find.text('This is an integration test answer'), findsOneWidget);

      // Go back to questions screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on the questions screen
      expect(find.byType(QuestionsScreen), findsOneWidget);
    });

    testWidgets('Search functionality test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Sign in
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Integration Test');
      await tester.pumpAndSettle();

      // Verify search results
      expect(find.text('Integration Test Question'), findsOneWidget);
    });
  });
}
