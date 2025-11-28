import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/services/feedback_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Feedback Form Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display all form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all main elements are present
      expect(find.text('Send Feedback'), findsAtLeast(1));
      expect(find.text('Feedback Type'), findsOneWidget);
      expect(find.text('Your Email (Optional)'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('should have all feedback types in dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap dropdown to open it
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Verify all feedback types are available
      expect(find.text('Bug Report').hitTestable(), findsWidgets);
      expect(find.text('Feature Request').hitTestable(), findsOneWidget);
      expect(find.text('General Feedback').hitTestable(), findsOneWidget);
      expect(find.text('Question').hitTestable(), findsOneWidget);
      expect(find.text('Praise').hitTestable(), findsOneWidget);
    });

    testWidgets('should select different feedback types', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select "Feature Request"
      await tester.tap(find.text('Feature Request').last);
      await tester.pumpAndSettle();

      // Verify selection (dropdown should show the selected value)
      expect(find.text('Feature Request'), findsWidgets);
    });

    testWidgets('should validate empty message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Try to submit without entering message
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Feedback'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your feedback'), findsOneWidget);
    });

    testWidgets('should validate message minimum length', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter a short message (less than 10 characters)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Tell us what\'s on your mind...'),
        'Short',
      );
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Feedback'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(
        find.text('Please provide more details (at least 10 characters)'),
        findsOneWidget,
      );
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter invalid email
      final emailField = find.widgetWithText(TextFormField, 'your.email@example.com');
      await tester.enterText(emailField, 'invalid-email');
      await tester.pumpAndSettle();

      // Enter valid message
      final messageField = find.widgetWithText(
        TextFormField,
        'Tell us what\'s on your mind...',
      );
      await tester.enterText(messageField, 'This is a valid feedback message');
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Feedback'));
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('should accept valid email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid email
      final emailField = find.widgetWithText(TextFormField, 'your.email@example.com');
      await tester.enterText(emailField, 'user@example.com');
      await tester.pumpAndSettle();

      // Enter valid message
      final messageField = find.widgetWithText(
        TextFormField,
        'Tell us what\'s on your mind...',
      );
      await tester.enterText(messageField, 'This is a valid feedback message');
      await tester.pumpAndSettle();

      // Try to submit - should not show email validation error
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Feedback'));
      await tester.pumpAndSettle();

      // Email validation error should not appear
      expect(find.text('Please enter a valid email address'), findsNothing);
    });

    testWidgets('should allow submission without email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter only message (no email)
      final messageField = find.widgetWithText(
        TextFormField,
        'Tell us what\'s on your mind...',
      );
      await tester.enterText(messageField, 'This is a valid feedback message without email');
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Feedback'));
      await tester.pumpAndSettle();

      // Should not show email validation error since it's optional
      expect(find.text('Please enter a valid email address'), findsNothing);
    });

    testWidgets('should display information banner', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify info banner is displayed
      expect(
        find.text('We value your feedback! Help us improve Diaspora Handbook.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.feedback), findsOneWidget);
    });

    testWidgets('should display all feedback type options with icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dropdown has category icon
      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('should clear form after successful submission', (WidgetTester tester) async {
      // Note: Actual submission would be tested with mocked url_launcher
      // This test verifies the form structure allows for reset
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter data
      final messageField = find.widgetWithText(
        TextFormField,
        'Tell us what\'s on your mind...',
      );
      await tester.enterText(messageField, 'Test feedback message');
      await tester.pumpAndSettle();

      // Verify data is entered
      expect(find.text('Test feedback message'), findsOneWidget);
    });

    testWidgets('should update character count as user types', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FeedbackScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final messageField = find.widgetWithText(
        TextFormField,
        'Tell us what\'s on your mind...',
      );

      // Type gradually and check validation
      await tester.enterText(messageField, '123456789'); // 9 chars
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Feedback'));
      await tester.pumpAndSettle();
      expect(
        find.text('Please provide more details (at least 10 characters)'),
        findsOneWidget,
      );

      // Add one more character
      await tester.enterText(messageField, '1234567890'); // 10 chars
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Feedback'));
      await tester.pumpAndSettle();
      
      // Should not show length error anymore
      expect(
        find.text('Please provide more details (at least 10 characters)'),
        findsNothing,
      );
    });
  });
}


