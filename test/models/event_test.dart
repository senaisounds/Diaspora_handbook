import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/models/event.dart';

void main() {
  group('Event Model Tests', () {
    test('should create Event instance correctly', () {
      // Arrange & Act
      final event = Event(
        id: 'test1',
        title: 'Test Event',
        description: 'Test Description',
        startTime: DateTime(2025, 1, 8, 13, 0),
        endTime: DateTime(2025, 1, 8, 19, 0),
        location: 'Test Location',
        category: 'Exhibition',
        color: const Color(0xFFFFD700),
        imageUrl: null,
      );

      // Assert
      expect(event.id, 'test1');
      expect(event.title, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.location, 'Test Location');
      expect(event.category, 'Exhibition');
    });

    test('should calculate duration correctly', () {
      // Arrange
      final event = Event(
        id: 'test1',
        title: 'Test Event',
        description: '',
        startTime: DateTime(2025, 1, 8, 13, 0),
        endTime: DateTime(2025, 1, 8, 19, 0), // 6 hours
        location: 'Test Location',
        category: 'Exhibition',
        color: const Color(0xFFFFD700),
      );

      // Act
      final duration = event.endTime.difference(event.startTime);

      // Assert
      expect(duration.inHours, 6);
    });

    test('should handle null imageUrl', () {
      // Arrange & Act
      final event = Event(
        id: 'test1',
        title: 'Test Event',
        description: '',
        startTime: DateTime(2025, 1, 8),
        endTime: DateTime(2025, 1, 8),
        location: 'Test Location',
        category: 'Exhibition',
        color: const Color(0xFFFFD700),
        imageUrl: null,
      );

      // Assert
      expect(event.imageUrl, isNull);
    });

    test('should compare events correctly', () {
      // Arrange
      final event1 = Event(
        id: 'test1',
        title: 'Event 1',
        description: '',
        startTime: DateTime(2025, 1, 8),
        endTime: DateTime(2025, 1, 8),
        location: 'Location 1',
        category: 'Category 1',
        color: const Color(0xFFFFD700),
      );

      final event2 = Event(
        id: 'test1',
        title: 'Event 1',
        description: '',
        startTime: DateTime(2025, 1, 8),
        endTime: DateTime(2025, 1, 8),
        location: 'Location 1',
        category: 'Category 1',
        color: const Color(0xFFFFD700),
      );

      // Assert
      expect(event1.id, event2.id);
    });
  });
}

