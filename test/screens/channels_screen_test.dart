import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:diaspora_handbook/screens/channels_screen.dart';
import 'package:diaspora_handbook/providers/chat_provider.dart';
import '../helpers/test_data.dart';

void main() {
  late ChatProvider chatProvider;

  setUp(() {
    chatProvider = ChatProvider();
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<ChatProvider>.value(
      value: chatProvider,
      child: const MaterialApp(
        home: ChannelsScreen(),
      ),
    );
  }

  group('ChannelsScreen Widget Tests', () {
    testWidgets('should display loading indicator when loading',
        (WidgetTester tester) async {
      // Arrange
      chatProvider.setLoading(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display channels list when loaded',
        (WidgetTester tester) async {
      // Arrange
      chatProvider.setChannels(TestData.allChannels);
      chatProvider.setLoading(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Announcements'), findsOneWidget);
      expect(find.text('#GENERAL'), findsOneWidget);
      expect(find.text('#DHEVENTS'), findsOneWidget);
    });

    testWidgets('should display "Groups you can join" header',
        (WidgetTester tester) async {
      // Arrange
      chatProvider.setChannels(TestData.allChannels);
      chatProvider.setLoading(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Groups you can join'), findsOneWidget);
    });

    testWidgets('should display member counts',
        (WidgetTester tester) async {
      // Arrange
      chatProvider.setChannels(TestData.allChannels);
      chatProvider.setLoading(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('267 members'), findsOneWidget);
      expect(find.text('335 members'), findsOneWidget);
    });

    testWidgets('should show "Add group" button',
        (WidgetTester tester) async {
      // Arrange
      chatProvider.setChannels(TestData.allChannels);
      chatProvider.setLoading(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Add group'), findsOneWidget);
    });

    testWidgets('should display error message when error occurs',
        (WidgetTester tester) async {
      // Arrange
      chatProvider.setError('Test error message');
      chatProvider.setLoading(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

