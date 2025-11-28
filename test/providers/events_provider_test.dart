import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:diaspora_handbook/providers/events_provider.dart';
import '../helpers/test_data.dart';
import '../mocks/mock_services.dart';

void main() {
  late EventsProvider eventsProvider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    eventsProvider = EventsProvider();
  });

  group('EventsProvider Tests', () {
    test('should start with empty events list', () {
      expect(eventsProvider.events, isEmpty);
      expect(eventsProvider.isLoading, isFalse);
      expect(eventsProvider.error, isNull);
    });

    test('should load events successfully', () async {
      // Arrange
      when(mockApiService.getEvents())
          .thenAnswer((_) async => TestData.allEvents);

      // Act
      await eventsProvider.loadEvents();

      // Assert
      expect(eventsProvider.events.length, 3);
      expect(eventsProvider.isLoading, isFalse);
      expect(eventsProvider.error, isNull);
    });

    test('should filter events by category', () {
      // Arrange
      eventsProvider.setEvents(TestData.allEvents);

      // Act
      final exhibitionEvents = eventsProvider.events
          .where((e) => e.category == 'Exhibition')
          .toList();

      // Assert
      expect(exhibitionEvents.length, 1);
      expect(exhibitionEvents.first.title, 'Test Event 1');
    });

    test('should filter events by date range', () {
      // Arrange
      eventsProvider.setEvents(TestData.allEvents);
      final startDate = DateTime(2025, 1, 9);
      final endDate = DateTime(2025, 1, 10);

      // Act
      final filteredEvents = eventsProvider.events
          .where((e) =>
              e.startTime.isAfter(startDate) && e.startTime.isBefore(endDate))
          .toList();

      // Assert
      expect(filteredEvents.length, 2);
    });

    test('should get event by id', () {
      // Arrange
      eventsProvider.setEvents(TestData.allEvents);

      // Act
      final event = eventsProvider.events.firstWhere((e) => e.id == 'event1');

      // Assert
      expect(event, isNotNull);
      expect(event.title, 'Test Event 1');
    });
  });
}

