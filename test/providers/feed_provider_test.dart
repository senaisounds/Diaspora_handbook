import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/providers/feed_provider.dart';
import '../helpers/fake_api_service.dart';

void main() {
  late FeedProvider feedProvider;
  late FakeApiService fakeApiService;

  setUp(() {
    fakeApiService = FakeApiService();
    feedProvider = FeedProvider(apiService: fakeApiService);
  });

  group('FeedProvider Tests', () {
    test('initial state should be empty', () {
      expect(feedProvider.posts, isEmpty);
      expect(feedProvider.isLoading, isFalse);
    });

    test('loadPosts should fetch posts successfully', () async {
      // Arrange
      final postsJson = [
        {
          'id': '1',
          'user_id': 'u1',
          'username': 'user1',
          'content': 'Hello world',
          'likes_count': 5,
          'is_liked': false,
          'created_at': DateTime.now().toIso8601String(),
        }
      ];

      fakeApiService.getResponse = postsJson;

      // Act
      await feedProvider.loadPosts();

      // Assert
      expect(feedProvider.posts.length, 1);
      expect(feedProvider.posts.first.content, 'Hello world');
      expect(feedProvider.isLoading, isFalse);
    });

    test('createPost should add new post to top of list', () async {
      // Arrange
      const content = 'New post';
      final newPostJson = {
        'id': '2',
        'user_id': 'u1',
        'username': 'user1',
        'content': content,
        'likes_count': 0,
        'is_liked': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      fakeApiService.postResponse = newPostJson;

      // Act
      await feedProvider.createPost(content);

      // Assert
      expect(feedProvider.posts.length, 1);
      expect(feedProvider.posts.first.content, content);
    });
  });
}
