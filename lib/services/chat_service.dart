import 'package:dio/dio.dart';
import '../models/channel.dart';
import '../models/message.dart';

class ChatService {
  final Dio _dio;
  final String baseUrl;

  ChatService({required this.baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: '$baseUrl/chat',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<List<Channel>> getChannels() async {
    try {
      final response = await _dio.get('/channels');
      return (response.data as List)
          .map((json) => Channel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch channels: $e');
    }
  }

  Future<List<Message>> getMessages(String channelId, {int limit = 50}) async {
    try {
      final response = await _dio.get(
        '/channels/$channelId/messages',
        queryParameters: {'limit': limit},
      );
      return (response.data as List)
          .map((json) => Message.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  Future<Map<String, dynamic>> createUser(
      String username, String deviceId) async {
    try {
      final response = await _dio.post('/users', data: {
        'username': username,
        'deviceId': deviceId,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> joinChannel(String channelId, String userId) async {
    try {
      await _dio.post('/channels/$channelId/join', data: {
        'userId': userId,
      });
    } catch (e) {
      throw Exception('Failed to join channel: $e');
    }
  }

  Future<Channel> createChannel({
    required String name,
    String? description,
    required String icon,
    String? emoji,
    bool isAnnouncement = false,
  }) async {
    try {
      final response = await _dio.post('/channels', data: {
        'name': name,
        'description': description,
        'icon': icon,
        'emoji': emoji,
        'isAnnouncement': isAnnouncement,
      });
      return Channel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create channel: $e');
    }
  }
}

