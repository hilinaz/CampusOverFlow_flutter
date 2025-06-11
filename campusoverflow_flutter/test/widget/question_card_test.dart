import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_project/screens/QuestionsScreen.dart';

void main() {
  group('QuestionCard Widget Tests', () {
    testWidgets('QuestionCard displays user name and question text',
        (WidgetTester tester) async {
      // Build our widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionCard(
              userName: 'Test User',
              questionText: 'Test Question',
              profession: 'Student',
              onSeeAnswersPressed: () {},
              currentUserId: '123',
              questionUserId: '123',
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify that the user name is displayed
      expect(find.text('Test User'), findsOneWidget);

      // Verify that the question text is displayed
      expect(find.text('Test Question'), findsOneWidget);

      // Verify that the profession is displayed
      expect(find.text('Student'), findsOneWidget);
    });

    testWidgets('QuestionCard shows edit option for own questions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionCard(
              userName: 'Test User',
              questionText: 'Test Question',
              profession: 'Student',
              onSeeAnswersPressed: () {},
              currentUserId: '123',
              questionUserId: '123', // Same as currentUserId
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(QuestionCard));
      await tester.pumpAndSettle();

      // Verify that the edit option is shown
      expect(find.text('Edit Question'), findsOneWidget);
    });

    testWidgets('QuestionCard does not show options for other users questions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionCard(
              userName: 'Test User',
              questionText: 'Test Question',
              profession: 'Student',
              onSeeAnswersPressed: () {},
              currentUserId: '123',
              questionUserId: '456', // Different from currentUserId
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(QuestionCard));
      await tester.pumpAndSettle();

      // Verify that no options are shown
      expect(find.text('Edit Question'), findsNothing);
    });
  });
} 