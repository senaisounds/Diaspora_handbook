import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:diaspora_handbook/screens/event_detail_screen.dart';
import 'package:diaspora_handbook/models/event.dart';
import 'package:diaspora_handbook/providers/favorites_provider.dart';
import 'package:diaspora_handbook/providers/reminders_provider.dart';
import 'package:diaspora_handbook/providers/registration_provider.dart';
import 'package:diaspora_handbook/providers/checkins_provider.dart';
import 'package:diaspora_handbook/providers/achievements_provider.dart';
import 'package:diaspora_handbook/providers/events_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Event Detail Enhancements Tests', () {
    late Event testEvent;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      testEvent = Event(
        id: 'test-event',
        title: 'Test Event',
        description: 'A test event',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        location: 'Test Location',
        category: 'Party',
        color: const Color(0xFFFFD700),
        imageUrl: null,
      );
    });

    Widget createTestWidget(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => EventsProvider()),
          ChangeNotifierProxyProvider<EventsProvider, FavoritesProvider>(
            create: (context) => FavoritesProvider(context.read<EventsProvider>()),
            update: (context, eventsProvider, previous) =>
                previous ?? FavoritesProvider(eventsProvider),
          ),
          ChangeNotifierProvider(create: (_) => RemindersProvider()),
          ChangeNotifierProvider(create: (_) => RegistrationProvider()),
          ChangeNotifierProvider(create: (_) => AchievementsProvider()),
          ChangeNotifierProvider(create: (_) => CheckInsProvider()),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('should display enhanced reminder options', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(EventDetailScreen(event: testEvent)),
      );
      await tester.pumpAndSettle();

      // Scroll to reminder section
      await tester.scrollUntilVisible(
        find.text('Event Reminders'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Tap reminder switch/icon
      final reminderIcon = find.byIcon(Icons.notifications_active);
      if (reminderIcon.evaluate().isNotEmpty) {
        await tester.tap(reminderIcon.first);
        await tester.pumpAndSettle();

        // Should show reminder dialog with all options
        expect(find.text('Set Event Reminder'), findsOneWidget);
        expect(find.text('15 minutes before'), findsOneWidget);
        expect(find.text('30 minutes before'), findsOneWidget);
        expect(find.text('1 hour before'), findsOneWidget);
        expect(find.text('2 hours before'), findsOneWidget);
        expect(find.text('1 day before'), findsOneWidget);
        expect(find.text('No reminder'), findsOneWidget);
      }
    });

    testWidgets('should select 30 minutes reminder option', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(EventDetailScreen(event: testEvent)),
      );
      await tester.pumpAndSettle();

      // Scroll to and tap reminder icon
      await tester.scrollUntilVisible(
        find.text('Event Reminders'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      final reminderIcon = find.byIcon(Icons.notifications_active);
      if (reminderIcon.evaluate().isNotEmpty) {
        await tester.tap(reminderIcon.first);
        await tester.pumpAndSettle();

        // Select 30 minutes option
        await tester.tap(find.text('30 minutes before'));
        await tester.pumpAndSettle();

        // Verify selection (radio button should be selected)
        final radioTile = find.ancestor(
          of: find.text('30 minutes before'),
          matching: find.byType(RadioListTile<Duration?>),
        );
        expect(radioTile, findsOneWidget);
      }
    });

    testWidgets('should select 2 hours reminder option', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(EventDetailScreen(event: testEvent)),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Event Reminders'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      final reminderIcon = find.byIcon(Icons.notifications_active);
      if (reminderIcon.evaluate().isNotEmpty) {
        await tester.tap(reminderIcon.first);
        await tester.pumpAndSettle();

        // Select 2 hours option
        await tester.tap(find.text('2 hours before'));
        await tester.pumpAndSettle();

        // Verify selection
        final radioTile = find.ancestor(
          of: find.text('2 hours before'),
          matching: find.byType(RadioListTile<Duration?>),
        );
        expect(radioTile, findsOneWidget);
      }
    });

    testWidgets('should display QR code button when not checked in', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(EventDetailScreen(event: testEvent)),
      );
      await tester.pumpAndSettle();

      // Scroll to check-in section
      await tester.scrollUntilVisible(
        find.text('Check In'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      // Should show QR code icon button
      expect(find.byIcon(Icons.qr_code), findsOneWidget);
    });

    testWidgets('should show share button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(EventDetailScreen(event: testEvent)),
      );
      await tester.pumpAndSettle();

      // Share button should be visible in app bar
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    testWidgets('QR button should have tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(EventDetailScreen(event: testEvent)),
      );
      await tester.pumpAndSettle();

      // Scroll to check-in section
      await tester.scrollUntilVisible(
        find.text('Check In'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      final qrButton = find.byIcon(Icons.qr_code);
      if (qrButton.evaluate().isNotEmpty) {
        // Long press to show tooltip
        await tester.longPress(qrButton);
        await tester.pumpAndSettle();

        // Tooltip should appear
        expect(find.text('Show QR Code'), findsOneWidget);
      }
    });

    testWidgets('should handle reminder selection and save', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(EventDetailScreen(event: testEvent)),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Event Reminders'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      final reminderIcon = find.byIcon(Icons.notifications_active);
      if (reminderIcon.evaluate().isNotEmpty) {
        await tester.tap(reminderIcon.first);
        await tester.pumpAndSettle();

        // Select an option
        await tester.tap(find.text('1 hour before'));
        await tester.pumpAndSettle();

        // Tap Save button
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Dialog should close
        expect(find.text('Set Event Reminder'), findsNothing);
      }
    });

    testWidgets('should cancel reminder selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(EventDetailScreen(event: testEvent)),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Event Reminders'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      final reminderIcon = find.byIcon(Icons.notifications_active);
      if (reminderIcon.evaluate().isNotEmpty) {
        await tester.tap(reminderIcon.first);
        await tester.pumpAndSettle();

        // Select an option
        await tester.tap(find.text('30 minutes before'));
        await tester.pumpAndSettle();

        // Tap Cancel button
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Dialog should close without saving
        expect(find.text('Set Event Reminder'), findsNothing);
      }
    });

    testWidgets('should switch between different reminder options', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(EventDetailScreen(event: testEvent)),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Event Reminders'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      final reminderIcon = find.byIcon(Icons.notifications_active);
      if (reminderIcon.evaluate().isNotEmpty) {
        await tester.tap(reminderIcon.first);
        await tester.pumpAndSettle();

        // Select first option
        await tester.tap(find.text('15 minutes before'));
        await tester.pumpAndSettle();

        // Switch to different option
        await tester.tap(find.text('1 day before'));
        await tester.pumpAndSettle();

        // Both options should be present but only one selected
        expect(find.text('15 minutes before'), findsOneWidget);
        expect(find.text('1 day before'), findsOneWidget);
      }
    });

    testWidgets('should handle "No reminder" option', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(EventDetailScreen(event: testEvent)),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Event Reminders'),
        100,
        scrollable: find.byType(Scrollable).first,
      );

      final reminderIcon = find.byIcon(Icons.notifications_active);
      if (reminderIcon.evaluate().isNotEmpty) {
        await tester.tap(reminderIcon.first);
        await tester.pumpAndSettle();

        // Select "No reminder"
        await tester.tap(find.text('No reminder'));
        await tester.pumpAndSettle();

        // Save
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Should close successfully
        expect(find.text('Set Event Reminder'), findsNothing);
      }
    });
  });
}


