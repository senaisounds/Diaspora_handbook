import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:diaspora_handbook/main.dart' as app;
import 'package:diaspora_handbook/screens/onboarding_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('New Features Integration Tests', () {
    setUp(() async {
      // Reset onboarding for testing
      await OnboardingScreen.resetOnboarding();
    });

    testWidgets('Complete onboarding flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should show onboarding on first launch
      expect(find.textContaining('Welcome to'), findsOneWidget);

      // Navigate through onboarding
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Complete onboarding
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to main screen
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Access feedback form from settings',
        (WidgetTester tester) async {
      // Mark onboarding as complete
      await OnboardingScreen.completeOnboarding();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Scroll to find Send Feedback
      await tester.dragUntilVisible(
        find.text('Send Feedback'),
        find.byType(ListView),
        const Offset(0, -100),
      );

      // Tap on Send Feedback
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      // Should show feedback form
      expect(find.text('Send Feedback'), findsWidgets);
    });

    testWidgets('Export schedule from favorites',
        (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to My Plan tab
      await tester.tap(find.text('My Plan'));
      await tester.pumpAndSettle();

      // If there are favorite events, the share button should be enabled
      final shareFinder = find.byIcon(Icons.share);
      if (tester.any(shareFinder)) {
        await tester.tap(shareFinder);
        await tester.pumpAndSettle();

        // Should show export options
        expect(
          find.textContaining('Export'),
          findsOneWidget,
        );
      }
    });

    testWidgets('View QR code for event', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap on first event card (if any exist)
      final eventCardFinder = find.byType(Card).first;
      if (tester.any(eventCardFinder)) {
        await tester.tap(eventCardFinder);
        await tester.pumpAndSettle();

        // Look for QR code button
        final qrButtonFinder = find.byIcon(Icons.qr_code);
        if (tester.any(qrButtonFinder)) {
          await tester.tap(qrButtonFinder);
          await tester.pumpAndSettle();

          // Should show QR code dialog
          expect(find.textContaining('QR Code'), findsOneWidget);

          // Close dialog
          await tester.tap(find.text('Done'));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Enhanced reminder options', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap on first event
      final eventCardFinder = find.byType(Card).first;
      if (tester.any(eventCardFinder)) {
        await tester.tap(eventCardFinder);
        await tester.pumpAndSettle();

        // Tap reminder button
        final reminderButtonFinder = find.byIcon(Icons.notifications_outlined);
        if (tester.any(reminderButtonFinder)) {
          await tester.tap(reminderButtonFinder);
          await tester.pumpAndSettle();

          // Should show new reminder options
          expect(find.text('30 minutes before'), findsOneWidget);
          expect(find.text('2 hours before'), findsOneWidget);

          // Close dialog
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Pull to refresh on home screen',
        (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Perform pull to refresh gesture
      await tester.fling(
        find.byType(ListView).first,
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // App should still be functional after refresh
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Show tutorial from settings', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Scroll to find Show Tutorial
      await tester.dragUntilVisible(
        find.text('Show Tutorial'),
        find.byType(ListView),
        const Offset(0, -100),
      );

      // Tap on Show Tutorial
      await tester.tap(find.text('Show Tutorial'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.textContaining('Reset Tutorial'), findsOneWidget);
      expect(find.text('Show Tutorial'), findsWidgets);

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });

  group('Feature Interaction Tests', () {
    testWidgets('Add event to favorites and export',
        (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find first event
      final eventCardFinder = find.byType(Card).first;
      if (tester.any(eventCardFinder)) {
        await tester.tap(eventCardFinder);
        await tester.pumpAndSettle();

        // Add to favorites
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        // Go back
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Navigate to My Plan
        await tester.tap(find.text('My Plan'));
        await tester.pumpAndSettle();

        // Should see the favorited event
        expect(find.byType(Card), findsWidgets);
      }
    });

    testWidgets('QR code and check-in flow', (WidgetTester tester) async {
      await OnboardingScreen.completeOnboarding();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final eventCardFinder = find.byType(Card).first;
      if (tester.any(eventCardFinder)) {
        await tester.tap(eventCardFinder);
        await tester.pumpAndSettle();

        // Show QR code
        final qrButtonFinder = find.byIcon(Icons.qr_code);
        if (tester.any(qrButtonFinder)) {
          await tester.tap(qrButtonFinder);
          await tester.pumpAndSettle();

          // Close QR dialog
          await tester.tap(find.text('Done'));
          await tester.pumpAndSettle();
        }

        // Check in
        final checkInFinder = find.text('Check In');
        if (tester.any(checkInFinder)) {
          await tester.tap(checkInFinder.first);
          await tester.pumpAndSettle();

          // Should show success message
          expect(find.textContaining('Checked in'), findsOneWidget);
        }
      }
    });
  });
}

