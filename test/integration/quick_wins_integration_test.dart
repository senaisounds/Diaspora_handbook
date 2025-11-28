import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:diaspora_handbook/main.dart' as app;
import 'package:diaspora_handbook/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Quick Wins Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await OnboardingScreen.resetOnboarding();
    });

    testWidgets('Complete onboarding flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show onboarding screen
      expect(find.text('Welcome to\nDiaspora Handbook'), findsOneWidget);

      // Navigate through onboarding pages
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();
      }

      // Complete onboarding
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Should now be on main screen
      expect(find.text('HOMECOMING'), findsOneWidget);
    });

    testWidgets('Skip onboarding', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Should go directly to main screen
      expect(find.text('HOMECOMING'), findsOneWidget);
    });

    testWidgets('Pull to refresh on home screen', (WidgetTester tester) async {
      // Mark onboarding as complete to skip it
      await OnboardingScreen.completeOnboarding();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be on home screen
      expect(find.text('HOMECOMING'), findsOneWidget);

      // Pull to refresh
      await tester.fling(
        find.byType(RefreshIndicator).first,
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // Verify refresh happened (check for loading indicator completion)
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Navigate to feedback form', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Home screen if not there
      if (find.text('HOMECOMING').evaluate().isEmpty) {
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
      }

      // Tap settings button
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Scroll to feedback button
      await tester.scrollUntilVisible(
        find.text('Send Feedback'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Tap feedback button
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      // Should show feedback form
      expect(find.text('Send Feedback'), findsWidgets);
      expect(find.text('Feedback Type'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('Export schedule flow', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to My Plan
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // If there are favorites, test export button
      if (find.byIcon(Icons.share).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.share));
        await tester.pumpAndSettle();

        // Should show export options dialog
        expect(find.text('Export Schedule'), findsOneWidget);
        expect(find.text('Export as PDF'), findsOneWidget);
        expect(find.text('Add All to Calendar'), findsOneWidget);
        expect(find.text('Share as Text'), findsOneWidget);
      }
    });

    testWidgets('Enhanced reminder options', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap an event
      final eventCard = find.byType(Card).first;
      if (eventCard.evaluate().isNotEmpty) {
        await tester.tap(eventCard);
        await tester.pumpAndSettle();

        // Tap reminder button
        await tester.tap(find.byIcon(Icons.notifications_active).first);
        await tester.pumpAndSettle();

        // Should show enhanced reminder options
        expect(find.text('Set Event Reminder'), findsOneWidget);
        expect(find.text('15 minutes before'), findsOneWidget);
        expect(find.text('30 minutes before'), findsOneWidget);
        expect(find.text('1 hour before'), findsOneWidget);
        expect(find.text('2 hours before'), findsOneWidget);
        expect(find.text('1 day before'), findsOneWidget);
      }
    });

    testWidgets('QR code generation', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap an event
      final eventCard = find.byType(Card).first;
      if (eventCard.evaluate().isNotEmpty) {
        await tester.tap(eventCard);
        await tester.pumpAndSettle();

        // Scroll to check-in section
        await tester.scrollUntilVisible(
          find.text('Check In'),
          100,
          scrollable: find.byType(Scrollable).first,
        );

        // Tap QR code button if not checked in
        final qrButton = find.byIcon(Icons.qr_code);
        if (qrButton.evaluate().isNotEmpty) {
          await tester.tap(qrButton);
          await tester.pumpAndSettle();

          // Should show QR code dialog
          expect(find.text('Check-in QR Code'), findsOneWidget);
          expect(find.text('Scan this code to check in to the event'), findsOneWidget);
        }
      }
    });

    testWidgets('Show tutorial from settings', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Scroll to tutorial button
      await tester.scrollUntilVisible(
        find.text('Show Tutorial'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Tap tutorial button
      await tester.tap(find.text('Show Tutorial'));
      await tester.pumpAndSettle();

      // Should show reset tutorial dialog
      expect(find.text('Reset Tutorial'), findsOneWidget);
      expect(
        find.text('Would you like to view the onboarding tutorial again?'),
        findsOneWidget,
      );
    });

    testWidgets('Event sharing', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap an event
      final eventCard = find.byType(Card).first;
      if (eventCard.evaluate().isNotEmpty) {
        await tester.tap(eventCard);
        await tester.pumpAndSettle();

        // Should see share button in app bar
        expect(find.byIcon(Icons.share_outlined), findsOneWidget);

        // Tapping share would open system share sheet
        // We can verify the button exists and is tappable
        final shareButton = find.byIcon(Icons.share_outlined);
        expect(tester.widget<IconButton>(shareButton).onPressed, isNotNull);
      }
    });

    testWidgets('Pull to refresh on schedule screen', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Schedule screen
      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();

      // Should be on schedule screen
      expect(find.text('Schedule'), findsOneWidget);

      // Pull to refresh
      await tester.fling(
        find.byType(RefreshIndicator).first,
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // Verify refresh happened
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Complete user journey', (WidgetTester tester) async {
      // Reset to fresh state
      await OnboardingScreen.resetOnboarding();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 1. Complete onboarding
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // 2. Browse home screen
      expect(find.text('HOMECOMING'), findsOneWidget);

      // 3. Navigate to Schedule
      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Schedule'), findsOneWidget);

      // 4. Navigate to My Plan
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      expect(find.text('My Plan'), findsOneWidget);

      // 5. Navigate to Community
      await tester.tap(find.byIcon(Icons.forum_outlined));
      await tester.pumpAndSettle();

      // 6. Back to Home
      await tester.tap(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.text('HOMECOMING'), findsOneWidget);

      // 7. Pull to refresh
      await tester.fling(
        find.byType(RefreshIndicator).first,
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // Journey completed successfully
      expect(find.text('HOMECOMING'), findsOneWidget);
    });
  });
}


