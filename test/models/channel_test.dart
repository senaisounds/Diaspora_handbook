import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/models/channel.dart';

void main() {
  group('Channel Model Tests', () {
    test('should create Channel from JSON', () {
      // Arrange
      final json = {
        'id': 'ch_test',
        'name': 'Test Channel',
        'description': 'Test Description',
        'icon': '💬',
        'emoji': '💬',
        'member_count': 100,
        'is_announcement': 0,
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      // Act
      final channel = Channel.fromJson(json);

      // Assert
      expect(channel.id, 'ch_test');
      expect(channel.name, 'Test Channel');
      expect(channel.memberCount, 100);
      expect(channel.isAnnouncement, isFalse);
    });

    test('should convert Channel to JSON', () {
      // Arrange
      final channel = Channel(
        id: 'ch_test',
        name: 'Test Channel',
        description: 'Test Description',
        icon: '💬',
        emoji: '💬',
        memberCount: 100,
        isAnnouncement: false,
        createdAt: DateTime(2025, 1, 1),
      );

      // Act
      final json = channel.toJson();

      // Assert
      expect(json['id'], 'ch_test');
      expect(json['name'], 'Test Channel');
      expect(json['member_count'], 100);
      expect(json['is_announcement'], 0);
    });

    test('should handle announcement channel correctly', () {
      // Arrange
      final channel = Channel(
        id: 'ch_announcements',
        name: 'Announcements',
        description: 'Important announcements',
        icon: '📢',
        memberCount: 0,
        isAnnouncement: true,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(channel.isAnnouncement, isTrue);
      expect(channel.memberCount, 0);
    });

    test('should copy channel with modifications', () {
      // Arrange
      final original = Channel(
        id: 'ch_test',
        name: 'Original Name',
        description: 'Original Description',
        icon: '💬',
        memberCount: 100,
        isAnnouncement: false,
        createdAt: DateTime.now(),
      );

      // Act
      final modified = original.copyWith(
        name: 'New Name',
        memberCount: 200,
      );

      // Assert
      expect(modified.id, original.id);
      expect(modified.name, 'New Name');
      expect(modified.memberCount, 200);
      expect(modified.description, original.description);
    });
  });
}

