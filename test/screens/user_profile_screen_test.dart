import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diaspora_handbook/screens/user_profile_screen.dart';
import 'package:diaspora_handbook/providers/auth_provider.dart';
import '../helpers/fake_api_service.dart';

void main() {
  late AuthProvider authProvider;
  late FakeApiService fakeApiService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeApiService = FakeApiService();
    authProvider = AuthProvider(apiService: fakeApiService);
  });

  Widget createWidgetUnderTest(String userId) {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: UserProfileScreen(userId: userId),
      ),
    );
  }

  group('UserProfileScreen Tests', () {
    testWidgets('displays loading indicator while fetching', (WidgetTester tester) async {
      // Arrange
      fakeApiService.getResponse = null; // Will be set later
      
      // Act
      await tester.pumpWidget(createWidgetUnderTest('user1'));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays user profile information', (WidgetTester tester) async {
      // Arrange - Use null avatar_url to avoid NetworkImage issues in tests
      final userJson = {
        'id': 'user1',
        'username': 'testuser',
        'avatar_url': null, // Avoid NetworkImage in tests
        'instagram_handle': 'testuser',
        'habesha_status': '100% Habesha',
        'post_count': 10,
      };
      fakeApiService.getResponse = {'user': userJson};

      // Act
      await tester.pumpWidget(createWidgetUnderTest('user1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // Allow async to complete

      // Assert
      expect(find.text('testuser'), findsOneWidget);
      expect(find.text('100% Habesha'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('@testuser'), findsOneWidget);
    });

    testWidgets('displays error message on failure', (WidgetTester tester) async {
      // Arrange
      fakeApiService.errorToThrow = Exception('User not found');

      // Act
      await tester.pumpWidget(createWidgetUnderTest('invalid'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // Allow async to complete

      // Assert
      expect(find.text('Failed to load profile'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows placeholder when no avatar', (WidgetTester tester) async {
      // Arrange
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
      await tester.pumpWidget(createWidgetUnderTest('user1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // Allow async to complete

      // Assert
      expect(find.text('T'), findsWidgets); // First letter of username
    });
  });
}

