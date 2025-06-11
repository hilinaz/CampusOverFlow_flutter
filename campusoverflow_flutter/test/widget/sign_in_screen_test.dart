import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_project/screens/SignInScreen.dart';

void main() {
  testWidgets('SignInScreen shows login form and handles input',
      (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );

    // Verify that the login form is displayed
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField),
        findsNWidgets(2)); // Email and password fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Sign in button

    // Enter email
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    expect(find.text('test@example.com'), findsOneWidget);

    // Enter password
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    expect(find.text('password123'), findsOneWidget);

    // Verify the sign in button is enabled
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
    expect(signInButton, findsOneWidget);
    expect(tester.widget<ElevatedButton>(signInButton).enabled, isTrue);
  });

  testWidgets('SignInScreen shows validation errors for empty fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );

    // Try to sign in without entering any data
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    // Verify validation messages
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('SignInScreen shows validation for invalid email',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );

    // Enter invalid email
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    // Verify email validation message
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });
}
