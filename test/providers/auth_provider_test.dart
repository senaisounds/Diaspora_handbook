import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diaspora_handbook/providers/auth_provider.dart';
import '../helpers/fake_api_service.dart';

void main() {
  late AuthProvider authProvider;
  late FakeApiService fakeApiService;

  setUp(() {
    fakeApiService = FakeApiService();
    SharedPreferences.setMockInitialValues({});
    authProvider = AuthProvider(apiService: fakeApiService);
  });

  group('AuthProvider Tests', () {
    test('initial state should be unauthenticated', () {
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);
      expect(authProvider.token, isNull);
    });

    test('login should succeed and set user', () async {
      // Arrange
      const username = 'testuser';
      const password = 'password123';
      const token = 'fake_token';
      final userJson = {
        'id': '1',
        'username': username,
        'email': 'test@example.com',
        'avatar_url': null,
        'instagram_handle': null,
        'habesha_status': null,
      };

      fakeApiService.postResponse = {'token': token, 'user': userJson};

      // Act
      await authProvider.login(username, password);

      // Assert
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.username, username);
      expect(authProvider.token, token);
      expect(authProvider.error, isNull);
      expect(fakeApiService.token, token);
    });

    test('login should fail and set error', () async {
      // Arrange
      const username = 'testuser';
      const password = 'wrongpassword';

      fakeApiService.errorToThrow = Exception('Invalid credentials');

      // Act & Assert
      await expectLater(
        authProvider.login(username, password),
        throwsException,
      );

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.error, contains('Invalid credentials'));
    });

    test('register should succeed with profile fields', () async {
      // Arrange
      const username = 'newuser';
      const email = 'new@example.com';
      const password = 'password123';
      const token = 'fake_token';
      final userJson = {
        'id': '2',
        'username': username,
        'email': email,
        'avatar_url': '/uploads/avatars/test.jpg',
        'instagram_handle': 'testuser',
        'habesha_status': '100%',
      };

      fakeApiService.postResponse = {'token': token, 'user': userJson};

      // Act
      await authProvider.register(
        username,
        email,
        password,
        instagram: 'testuser',
        habeshaStatus: '100%',
      );

      // Assert
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.user?.username, username);
      expect(authProvider.user?.instagramHandle, 'testuser');
      expect(authProvider.user?.habeshaStatus, '100%');
      expect(authProvider.user?.avatarUrl, '/uploads/avatars/test.jpg');
    });

    test('updateProfile should update user profile', () async {
      // Arrange - First login
      const token = 'fake_token';
      final initialUserJson = {
        'id': '1',
        'username': 'testuser',
        'email': 'test@example.com',
        'avatar_url': null,
        'instagram_handle': null,
        'habesha_status': null,
      };
      
      fakeApiService.postResponse = {'token': token, 'user': initialUserJson};
      await authProvider.login('testuser', 'password');

      // Update profile response
      final updatedUserJson = {
        'id': '1',
        'username': 'testuser',
        'email': 'test@example.com',
        'avatar_url': '/uploads/avatars/new.jpg',
        'instagram_handle': '@updated',
        'habesha_status': 'Updated status',
      };
      fakeApiService.putResponse = {'user': updatedUserJson};

      // Act
      await authProvider.updateProfile(
        instagram: 'updated',
        habeshaStatus: 'Updated status',
      );

      // Assert - Backend returns with @ prefix for instagram
      expect(authProvider.user?.instagramHandle, '@updated');
      expect(authProvider.user?.habeshaStatus, 'Updated status');
    });

    test('getUserProfile should fetch user by ID', () async {
      // Arrange
      final userJson = {
        'id': '3',
        'username': 'otheruser',
        'avatar_url': '/uploads/avatars/other.jpg',
        'instagram_handle': 'otheruser',
        'habesha_status': '50%',
        'post_count': 5,
      };

      fakeApiService.getResponse = {'user': userJson};

      // Act
      final user = await authProvider.getUserProfile('3');

      // Assert
      expect(user.id, '3');
      expect(user.username, 'otheruser');
      expect(user.instagramHandle, 'otheruser');
      expect(user.habeshaStatus, '50%');
    });

    test('logout should clear user and token', () async {
      // Arrange - First login
      const token = 'fake_token';
      final userJson = {
        'id': '1',
        'username': 'testuser',
      };
      
      fakeApiService.postResponse = {'token': token, 'user': userJson};
      await authProvider.login('testuser', 'password');
      
      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.user, isNull);
      expect(authProvider.token, isNull);
      expect(fakeApiService.token, isNull);
    });
  });
}
