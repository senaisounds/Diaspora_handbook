import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/providers/chat_provider.dart';
import '../helpers/test_data.dart';

void main() {
  late ChatProvider chatProvider;

  setUp(() {
    chatProvider = ChatProvider();
  });

  group('ChatProvider Tests', () {
    test('should start with empty state', () {
      expect(chatProvider.channels, isEmpty);
      expect(chatProvider.currentMessages, isEmpty);
      expect(chatProvider.currentUser, isNull);
      expect(chatProvider.isLoading, isFalse);
    });

    test('should handle channel loading', () {
      // Arrange
      chatProvider.setChannels(TestData.allChannels);

      // Assert
      expect(chatProvider.channels.length, 3);
    });

    test('should filter announcement channels', () {
      // Arrange
      chatProvider.setChannels(TestData.allChannels);

      // Act
      final announcements =
          chatProvider.channels.where((c) => c.isAnnouncement).toList();

      // Assert
      expect(announcements.length, 1);
      expect(announcements.first.name, 'Announcements');
    });

    test('should filter regular channels', () {
      // Arrange
      chatProvider.setChannels(TestData.allChannels);

      // Act
      final regularChannels =
          chatProvider.channels.where((c) => !c.isAnnouncement).toList();

      // Assert
      expect(regularChannels.length, 2);
    });

    test('should get messages for channel', () {
      // Arrange
      chatProvider.setMessages('ch_general', TestData.generalMessages);

      // Act
      chatProvider.setCurrentChannel('ch_general');

      // Assert
      expect(chatProvider.currentMessages.length, 2);
    });

    test('should handle connection status', () {
      expect(chatProvider.isConnected, isFalse);
    });
  });
}

