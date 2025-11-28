import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/services/export_service.dart';
import 'package:diaspora_handbook/models/event.dart';
import 'package:flutter/material.dart';

void main() {
  group('ExportService', () {
    late ExportService exportService;
    late List<Event> testEvents;

    setUp(() {
      exportService = ExportService();
      testEvents = [
        Event(
          id: 'event-1',
          title: 'Morning Yoga Session',
          description: 'Start your day with energizing yoga',
          startTime: DateTime(2025, 1, 15, 8, 0),
          endTime: DateTime(2025, 1, 15, 9, 30),
          location: 'City Park',
          category: 'Wellness',
          color: const Color(0xFF4CAF50),
          imageUrl: null,
        ),
        Event(
          id: 'event-2',
          title: 'Tech Conference 2025',
          description: 'Annual technology conference',
          startTime: DateTime(2025, 1, 15, 14, 0),
          endTime: DateTime(2025, 1, 15, 18, 0),
          location: 'Convention Center',
          category: 'Conference',
          color: const Color(0xFF2196F3),
          imageUrl: 'https://example.com/tech.jpg',
        ),
        Event(
          id: 'event-3',
          title: 'Evening Concert',
          description: 'Live music performance',
          startTime: DateTime(2025, 1, 16, 19, 0),
          endTime: DateTime(2025, 1, 16, 22, 0),
          location: 'Music Hall',
          category: 'Performance',
          color: const Color(0xFFE91E63),
          imageUrl: null,
        ),
      ];
    });

    group('generateTextSummary', () {
      test('should generate non-empty summary', () {
        final summary = exportService.generateTextSummary(testEvents);

        expect(summary, isNotEmpty);
      });

      test('should include app title in summary', () {
        final summary = exportService.generateTextSummary(testEvents);

        expect(summary, contains('MY HOMECOMING SCHEDULE'));
        expect(summary, contains('Diaspora Handbook'));
      });

      test('should include all event titles', () {
        final summary = exportService.generateTextSummary(testEvents);

        expect(summary, contains('Morning Yoga Session'));
        expect(summary, contains('Tech Conference 2025'));
        expect(summary, contains('Evening Concert'));
      });

      test('should include all event locations', () {
        final summary = exportService.generateTextSummary(testEvents);

        expect(summary, contains('City Park'));
        expect(summary, contains('Convention Center'));
        expect(summary, contains('Music Hall'));
      });

      test('should include all event categories', () {
        final summary = exportService.generateTextSummary(testEvents);

        expect(summary, contains('Wellness'));
        expect(summary, contains('Conference'));
        expect(summary, contains('Performance'));
      });

      test('should include total event count', () {
        final summary = exportService.generateTextSummary(testEvents);

        expect(summary, contains('Total Events: 3'));
      });

      test('should format dates correctly', () {
        final summary = exportService.generateTextSummary(testEvents);

        expect(summary, contains('WEDNESDAY, JANUARY 15'));
        expect(summary, contains('THURSDAY, JANUARY 16'));
      });

      test('should use emojis for visual appeal', () {
        final summary = exportService.generateTextSummary(testEvents);

        expect(summary, contains('📅'));
        expect(summary, contains('🎉'));
        expect(summary, contains('⏰'));
        expect(summary, contains('📍'));
        expect(summary, contains('🏷️'));
      });

      test('should handle empty event list', () {
        final summary = exportService.generateTextSummary([]);

        expect(summary, contains('MY HOMECOMING SCHEDULE'));
        expect(summary, contains('Total Events: 0'));
      });

      test('should handle single event', () {
        final summary = exportService.generateTextSummary([testEvents[0]]);

        expect(summary, contains('Morning Yoga Session'));
        expect(summary, contains('Total Events: 1'));
        expect(summary, isNot(contains('Tech Conference')));
      });

      test('should group events by date', () {
        final summary = exportService.generateTextSummary(testEvents);

        // Events on Jan 15 should appear before Jan 16
        final jan15Index = summary.indexOf('JANUARY 15');
        final jan16Index = summary.indexOf('JANUARY 16');
        final yoga = summary.indexOf('Morning Yoga Session');
        final concert = summary.indexOf('Evening Concert');

        expect(jan15Index, lessThan(jan16Index));
        expect(yoga, lessThan(concert));
      });

      test('should sort events by start time within same day', () {
        final summary = exportService.generateTextSummary(testEvents);

        // Morning event should appear before afternoon event
        final yogaIndex = summary.indexOf('Morning Yoga Session');
        final techIndex = summary.indexOf('Tech Conference 2025');

        expect(yogaIndex, lessThan(techIndex));
      });
    });

    group('generateTextSummary with various scenarios', () {
      test('should handle events with long descriptions', () {
        final eventWithLongDesc = Event(
          id: 'long-desc',
          title: 'Test Event',
          description: 'A' * 500, // Very long description
          startTime: DateTime(2025, 1, 15, 10, 0),
          endTime: DateTime(2025, 1, 15, 12, 0),
          location: 'Test Location',
          category: 'Test',
          color: const Color(0xFFFFD700),
          imageUrl: null,
        );

        final summary = exportService.generateTextSummary([eventWithLongDesc]);

        expect(summary, contains('Test Event'));
        expect(summary, isNotEmpty);
      });

      test('should handle events with special characters in title', () {
        final eventWithSpecialChars = Event(
          id: 'special',
          title: 'Test & Event "Special" \'Chars\'',
          description: 'Test description',
          startTime: DateTime(2025, 1, 15, 10, 0),
          endTime: DateTime(2025, 1, 15, 12, 0),
          location: 'Test Location',
          category: 'Test',
          color: const Color(0xFFFFD700),
          imageUrl: null,
        );

        final summary = exportService.generateTextSummary([eventWithSpecialChars]);

        expect(summary, contains('Test & Event "Special" \'Chars\''));
      });

      test('should handle multiple events on same day', () {
        final sameDay = [
          Event(
            id: 'event-a',
            title: 'Event A',
            description: 'First',
            startTime: DateTime(2025, 1, 15, 9, 0),
            endTime: DateTime(2025, 1, 15, 10, 0),
            location: 'Location A',
            category: 'Category A',
            color: const Color(0xFFFFD700),
            imageUrl: null,
          ),
          Event(
            id: 'event-b',
            title: 'Event B',
            description: 'Second',
            startTime: DateTime(2025, 1, 15, 11, 0),
            endTime: DateTime(2025, 1, 15, 12, 0),
            location: 'Location B',
            category: 'Category B',
            color: const Color(0xFFFFD700),
            imageUrl: null,
          ),
          Event(
            id: 'event-c',
            title: 'Event C',
            description: 'Third',
            startTime: DateTime(2025, 1, 15, 15, 0),
            endTime: DateTime(2025, 1, 15, 16, 0),
            location: 'Location C',
            category: 'Category C',
            color: const Color(0xFFFFD700),
            imageUrl: null,
          ),
        ];

        final summary = exportService.generateTextSummary(sameDay);

        expect(summary, contains('Event A'));
        expect(summary, contains('Event B'));
        expect(summary, contains('Event C'));
        
        // All should be under same date header
        final dateHeaders = 'JANUARY 15'.allMatches(summary).length;
        expect(dateHeaders, equals(1));
      });
    });
  });
}

