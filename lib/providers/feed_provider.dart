import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';

class FeedProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FeedProvider({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<dynamic> data = await _apiService.get('/feed');
      _posts = data.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(String content) async {
    try {
      final response = await _apiService.post('/feed', {
        'content': content,
      });
      final newPost = Post.fromJson(response);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleLike(String postId) async {
    // Optimistic update
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final newIsLiked = !post.isLiked;
    final newLikesCount = newIsLiked ? post.likesCount + 1 : post.likesCount - 1;

    // Update locally
    _posts[index] = Post(
      id: post.id,
      userId: post.userId,
      username: post.username,
      avatarUrl: post.avatarUrl,
      content: post.content,
      imageUrl: post.imageUrl,
      likesCount: newLikesCount,
      isLiked: newIsLiked,
      createdAt: post.createdAt,
    );
    notifyListeners();

    try {
      await _apiService.post('/feed/$postId/like', {});
    } catch (e) {
      // Revert if failed
      _posts[index] = post;
      notifyListeners();
      print('Error liking post: $e');
    }
  }
}

