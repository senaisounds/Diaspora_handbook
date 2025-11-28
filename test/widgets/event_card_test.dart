import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:diaspora_handbook/widgets/event_card.dart';
import 'package:diaspora_handbook/providers/favorites_provider.dart';
import 'package:diaspora_handbook/providers/events_provider.dart';
import '../helpers/test_data.dart';

void main() {
  late EventsProvider eventsProvider;
  late FavoritesProvider favoritesProvider;

  setUp(() {
    eventsProvider = EventsProvider();
    eventsProvider.setEvents(TestData.allEvents);
    favoritesProvider = FavoritesProvider(eventsProvider);
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EventsProvider>.value(value: eventsProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(value: favoritesProvider),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('EventCard Widget Tests', () {
    testWidgets('should display event information', (WidgetTester tester) async {
      // Arrange
      final event = TestData.event1;

      // Act
      await tester.pumpWidget(
        createTestWidget(EventCard(event: event)),
      );

      // Assert
      expect(find.text('Test Event 1'), findsOneWidget);
      expect(find.text('Venue TBD'), findsOneWidget);
    });

    testWidgets('should display event time', (WidgetTester tester) async {
      // Arrange
      final event = TestData.event1;

      // Act
      await tester.pumpWidget(
        createTestWidget(EventCard(event: event)),
      );

      // Assert
      expect(find.textContaining('1:00 PM'), findsOneWidget);
      expect(find.textContaining('7:00 AM'), findsOneWidget);
    });

    testWidgets('should show favorite icon when event is favorited',
        (WidgetTester tester) async {
      // Arrange
      final event = TestData.event1;
      await favoritesProvider.toggleFavorite(event.id);

      // Act
      await tester.pumpWidget(
        createTestWidget(EventCard(event: event)),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}

