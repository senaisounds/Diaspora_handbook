import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diaspora_handbook/screens/feed_screen.dart';
import 'package:diaspora_handbook/providers/feed_provider.dart';
import 'package:diaspora_handbook/providers/auth_provider.dart';
import '../helpers/fake_api_service.dart';

void main() {
  late FeedProvider feedProvider;
  late AuthProvider authProvider;
  late FakeApiService fakeApiService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeApiService = FakeApiService();
    feedProvider = FeedProvider(apiService: fakeApiService);
    authProvider = AuthProvider(apiService: fakeApiService);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FeedProvider>.value(value: feedProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: MaterialApp(
        home: const FeedScreen(),
      ),
    );
  }

  group('FeedScreen User Profile Navigation Tests', () {
    testWidgets('avatar is tappable and navigates to user profile', (WidgetTester tester) async {
      // Arrange
      final postsJson = [
        {
          'id': '1',
          'user_id': 'user1',
          'username': 'testuser',
          'avatar_url': null,
          'content': 'Test post',
          'likes_count': 0,
          'is_liked': false,
          'created_at': DateTime.now().toIso8601String(),
        }
      ];
      fakeApiService.getResponse = postsJson;
      
      // Pre-load posts to avoid hanging
      await feedProvider.loadPosts();
      
      // Set up user profile response for navigation (after posts are loaded)
      final userJson = {
        'id': 'user1',
        'username': 'testuser',
        'avatar_url': null,
        'instagram_handle': null,
        'habesha_status': null,
        'post_count': 0,
      };
      fakeApiService.getResponse = {'user': userJson};
      
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // Give time for UI to render
      
      // Find the avatar (CircleAvatar)
      final avatarFinder = find.byType(CircleAvatar).first;
      expect(avatarFinder, findsOneWidget);

      // Tap the avatar
      await tester.tap(avatarFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // Allow navigation

      // Assert - Should navigate to UserProfileScreen
      expect(find.text('Profile'), findsOneWidget); // AppBar title
    });

    testWidgets('username is tappable and navigates to user profile', (WidgetTester tester) async {
      // Arrange
      final postsJson = [
        {
          'id': '1',
          'user_id': 'user2',
          'username': 'anotheruser',
          'avatar_url': null,
          'content': 'Another post',
          'likes_count': 0,
          'is_liked': false,
          'created_at': DateTime.now().toIso8601String(),
        }
      ];
      fakeApiService.getResponse = postsJson;
      
      // Pre-load posts to avoid hanging
      await feedProvider.loadPosts();
      
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // Give time for UI to render

      // Find the username text
      final usernameFinder = find.text('anotheruser');
      expect(usernameFinder, findsOneWidget);

      // Set up user profile response for navigation
      final userJson = {
        'id': 'user2',
        'username': 'anotheruser',
        'avatar_url': null,
        'instagram_handle': null,
        'habesha_status': null,
        'post_count': 0,
      };
      fakeApiService.getResponse = {'user': userJson};
      
      // Tap the username
      await tester.tap(usernameFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // Allow navigation

      // Assert - Should navigate to UserProfileScreen
      expect(find.text('Profile'), findsOneWidget); // AppBar title
    });

    testWidgets('displays post content correctly', (WidgetTester tester) async {
      // Arrange
      final postsJson = [
        {
          'id': '1',
          'user_id': 'user1',
          'username': 'testuser',
          'avatar_url': null,
          'content': 'This is a test post',
          'likes_count': 5,
          'is_liked': true,
          'created_at': DateTime.now().toIso8601String(),
        }
      ];
      fakeApiService.getResponse = postsJson;
      
      // Pre-load posts to avoid hanging
      await feedProvider.loadPosts();
      
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // Give time for UI to render

      // Assert
      expect(find.text('This is a test post'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // Like count
      expect(find.byIcon(Icons.favorite), findsOneWidget); // Liked icon
    });
  });
}

