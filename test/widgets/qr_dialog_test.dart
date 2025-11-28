import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/services/qr_service.dart';
import 'package:diaspora_handbook/models/event.dart';

void main() {
  group('QR Code Dialog Widget Tests', () {
    late Event testEvent;
    late QRService qrService;

    setUp(() {
      testEvent = Event(
        id: 'test-event-123',
        title: 'Test Event',
        description: 'A test event for QR code',
        startTime: DateTime(2025, 1, 15, 18, 0),
        endTime: DateTime(2025, 1, 15, 22, 0),
        location: 'Test Venue',
        category: 'Party',
        color: const Color(0xFFFFD700),
        imageUrl: null,
      );
      qrService = QRService();
    });

    testWidgets('should display QR code dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => qrService.showQRCodeDialog(context, testEvent),
                  child: const Text('Show QR'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show QR'));
      await tester.pumpAndSettle();

      // Verify dialog elements
      expect(find.text('Check-in QR Code'), findsOneWidget);
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('Scan this code to check in to the event'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('should close QR code dialog when Done is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => qrService.showQRCodeDialog(context, testEvent),
                  child: const Text('Show QR'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show QR'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('Check-in QR Code'), findsOneWidget);

      // Tap Done button
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Check-in QR Code'), findsNothing);
    });

    testWidgets('should close QR code dialog when close icon is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => qrService.showQRCodeDialog(context, testEvent),
                  child: const Text('Show QR'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show QR'));
      await tester.pumpAndSettle();

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Check-in QR Code'), findsNothing);
    });

    testWidgets('should display event color in Done button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => qrService.showQRCodeDialog(context, testEvent),
                  child: const Text('Show QR'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show QR'));
      await tester.pumpAndSettle();

      // Find Done button and verify it has styling
      final doneButton = find.widgetWithText(ElevatedButton, 'Done');
      expect(doneButton, findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(doneButton);
      expect(button.style?.backgroundColor, isNotNull);
    });

    testWidgets('should handle events with long titles', (WidgetTester tester) async {
      final longTitleEvent = Event(
        id: 'long-title',
        title: 'This is a very long event title that should be displayed properly in the QR code dialog',
        description: 'Test',
        startTime: DateTime(2025, 1, 15, 18, 0),
        endTime: DateTime(2025, 1, 15, 22, 0),
        location: 'Test',
        category: 'Test',
        color: const Color(0xFFFFD700),
        imageUrl: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => qrService.showQRCodeDialog(context, longTitleEvent),
                  child: const Text('Show QR'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show QR'));
      await tester.pumpAndSettle();

      // Should display the long title
      expect(find.textContaining('This is a very long event title'), findsOneWidget);
    });
  });
}


