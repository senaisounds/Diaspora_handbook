import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/models/message.dart';

void main() {
  group('Message Model Tests', () {
    test('should create Message from JSON', () {
      // Arrange
      final json = {
        'id': 'msg_test',
        'channel_id': 'ch_general',
        'user_id': 'user1',
        'username': 'TestUser',
        'content': 'Hello World!',
        'message_type': 'text',
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      // Act
      final message = Message.fromJson(json);

      // Assert
      expect(message.id, 'msg_test');
      expect(message.channelId, 'ch_general');
      expect(message.userId, 'user1');
      expect(message.username, 'TestUser');
      expect(message.content, 'Hello World!');
      expect(message.messageType, 'text');
    });

    test('should convert Message to JSON', () {
      // Arrange
      final message = Message(
        id: 'msg_test',
        channelId: 'ch_general',
        userId: 'user1',
        username: 'TestUser',
        content: 'Hello World!',
        messageType: 'text',
        createdAt: DateTime(2025, 1, 1),
      );

      // Act
      final json = message.toJson();

      // Assert
      expect(json['id'], 'msg_test');
      expect(json['channel_id'], 'ch_general');
      expect(json['user_id'], 'user1');
      expect(json['content'], 'Hello World!');
    });

    test('should identify system messages', () {
      // Arrange
      final systemMessage = Message(
        id: 'msg_system',
        channelId: 'ch_general',
        userId: 'system',
        username: 'System',
        content: 'Welcome!',
        createdAt: DateTime.now(),
      );

      final userMessage = Message(
        id: 'msg_user',
        channelId: 'ch_general',
        userId: 'user1',
        username: 'TestUser',
        content: 'Hello!',
        createdAt: DateTime.now(),
      );

      // Assert
      expect(systemMessage.isSystemMessage, isTrue);
      expect(userMessage.isSystemMessage, isFalse);
    });
  });

  group('ChatUser Model Tests', () {
    test('should create ChatUser from JSON', () {
      // Arrange
      final json = {
        'id': 'user1',
        'username': 'TestUser',
        'device_id': 'device123',
        'created_at': '2025-01-01T00:00:00.000Z',
      };

      // Act
      final user = ChatUser.fromJson(json);

      // Assert
      expect(user.id, 'user1');
      expect(user.username, 'TestUser');
      expect(user.deviceId, 'device123');
    });

    test('should convert ChatUser to JSON', () {
      // Arrange
      final user = ChatUser(
        id: 'user1',
        username: 'TestUser',
        deviceId: 'device123',
        createdAt: DateTime(2025, 1, 1),
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], 'user1');
      expect(json['username'], 'TestUser');
      expect(json['device_id'], 'device123');
    });
  });
}

