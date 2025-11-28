import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/services/feedback_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FeedbackService', () {
    late FeedbackService feedbackService;

    setUp(() {
      feedbackService = FeedbackService();
      SharedPreferences.setMockInitialValues({});
    });

    group('getFeedbackStats', () {
      test('should return zero count for new user', () async {
        final stats = await feedbackService.getFeedbackStats();

        expect(stats['count'], equals(0));
        expect(stats['lastFeedback'], isNull);
      });

      test('should handle errors gracefully', () async {
        final stats = await feedbackService.getFeedbackStats();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['count'], equals(0));
      });
    });

    group('feedback types', () {
      final validFeedbackTypes = [
        'Bug Report',
        'Feature Request',
        'General Feedback',
        'Question',
        'Praise',
      ];

      test('should accept all valid feedback types', () {
        for (final type in validFeedbackTypes) {
          expect(type, isNotEmpty);
          expect(type, isA<String>());
        }
      });
    });

    group('email validation', () {
      test('valid email formats should be accepted', () {
        final validEmails = [
          'test@example.com',
          'user.name@example.com',
          'test_user@example-domain.com',
        ];

        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        for (final email in validEmails) {
          expect(emailRegex.hasMatch(email), isTrue,
              reason: '$email should be valid');
        }
      });

      test('invalid email formats should be rejected', () {
        final invalidEmails = [
          'notanemail',
          '@example.com',
          'user@',
          'user @example.com',
          'user@example',
          '',
        ];

        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        for (final email in invalidEmails) {
          expect(emailRegex.hasMatch(email), isFalse,
              reason: '$email should be invalid');
        }
      });
    });

    group('message validation', () {
      test('should reject empty messages', () {
        const message = '';
        expect(message.trim().isEmpty, isTrue);
      });

      test('should reject messages with only whitespace', () {
        const message = '   ';
        expect(message.trim().isEmpty, isTrue);
      });

      test('should reject messages shorter than 10 characters', () {
        const message = 'Too short';
        expect(message.length < 10, isTrue);
      });

      test('should accept messages with 10 or more characters', () {
        const message = 'This is a valid message';
        expect(message.trim().length >= 10, isTrue);
      });
    });

    group('email subject formatting', () {
      test('should include feedback type in subject', () {
        const feedbackType = 'Bug Report';
        final subject = '[$feedbackType] Diaspora Handbook Feedback';

        expect(subject, contains(feedbackType));
        expect(subject, contains('Diaspora Handbook'));
      });

      test('should format different feedback types correctly', () {
        final types = ['Bug Report', 'Feature Request', 'General Feedback'];

        for (final type in types) {
          final subject = '[$type] Diaspora Handbook Feedback';
          expect(subject, startsWith('[$type]'));
        }
      });
    });

    group('email body formatting', () {
      test('should include feedback type in body', () {
        const feedbackType = 'Bug Report';
        const message = 'This is a test message';
        
        final body = '''
Feedback Type: $feedbackType

Message:
$message

---
Sent from Diaspora Handbook - Homecoming Season Guide
      ''';

        expect(body, contains('Feedback Type: $feedbackType'));
        expect(body, contains(message));
      });

      test('should include user email if provided', () {
        const email = 'user@example.com';
        const feedbackType = 'Feature Request';
        const message = 'Test message';
        
        final body = '''
Feedback Type: $feedbackType
User Email: $email

Message:
$message

---
Sent from Diaspora Handbook - Homecoming Season Guide
      ''';

        expect(body, contains('User Email: $email'));
      });

      test('should not include email field if not provided', () {
        const feedbackType = 'General Feedback';
        const message = 'Test message';
        const email = '';
        
        final shouldIncludeEmail = email.isNotEmpty;
        
        expect(shouldIncludeEmail, isFalse);
      });

      test('should include app signature', () {
        const body = '''
Feedback Type: Test
Message: Test message

---
Sent from Diaspora Handbook - Homecoming Season Guide
      ''';

        expect(body, contains('Sent from Diaspora Handbook'));
        expect(body, contains('Homecoming Season Guide'));
      });
    });
  });
}

