import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:diaspora_handbook/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('should navigate through main screens',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify home screen is displayed
      expect(find.text('Home'), findsOneWidget);

      // Navigate to Schedule tab
      await tester.tap(find.text('Schedule'));
      await tester.pumpAndSettle();

      // Verify schedule screen is displayed
      expect(find.byIcon(Icons.calendar_month), findsWidgets);

      // Navigate to My Plan tab
      await tester.tap(find.text('My Plan'));
      await tester.pumpAndSettle();

      // Navigate to Community tab
      await tester.tap(find.text('Community'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify community screen is displayed
      expect(find.text('Groups you can join'), findsOneWidget);
    });

    testWidgets('should search for events', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap search field
      final searchField = find.byType(TextField).first;
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(searchField, 'Design');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify search results
      expect(find.textContaining('Design'), findsWidgets);
    });

    testWidgets('should toggle favorite on event',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find first event card
      final favoriteButton = find.byIcon(Icons.favorite_border).first;

      // Tap favorite button
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();

      // Verify event is favorited
      expect(find.byIcon(Icons.favorite), findsWidgets);

      // Navigate to My Plan
      await tester.tap(find.text('My Plan'));
      await tester.pumpAndSettle();

      // Verify favorited event appears
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should open channel and display chat',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Community
      await tester.tap(find.text('Community'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap a channel
      final channel = find.text('#GENERAL');
      if (channel.evaluate().isNotEmpty) {
        await tester.tap(channel);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify chat screen is displayed
        expect(find.byType(TextField), findsOneWidget);
      }
    });
  });
}

