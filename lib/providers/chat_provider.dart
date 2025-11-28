import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/channel.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  IO.Socket? _socket;
  List<Channel> _channels = [];
  final Map<String, List<Message>> _messages = {};
  ChatUser? _currentUser;
  String? _currentChannelId;
  bool _isLoading = false;
  String? _error;

  List<Channel> get channels => _channels;
  List<Message> get currentMessages => _messages[_currentChannelId] ?? [];
  ChatUser? get currentUser => _currentUser;
  String? get currentChannelId => _currentChannelId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _socket?.connected ?? false;

  // Helper to format error messages
  String _formatError(dynamic e) {
    return e.toString().replaceAll('Exception: ', '');
  }

  // Initialize chat service
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize or get user
      await _initializeUser();
      
      // Connect to socket
      _connectSocket();
      
      // Load channels
      await loadChannels();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _formatError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize user
  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('chat_user_id');
    
    if (userId == null) {
      // Create new user
      final deviceId = const Uuid().v4();
      final username = 'User${DateTime.now().millisecondsSinceEpoch % 10000}';
      
      final response = await _apiService.post('/chat/users', {
        'username': username,
        'deviceId': deviceId,
      });
      
      _currentUser = ChatUser.fromJson(response);
      await prefs.setString('chat_user_id', _currentUser!.id);
      await prefs.setString('chat_username', _currentUser!.username);
    } else {
      // Load existing user
      final username = prefs.getString('chat_username') ?? 'User';
      final deviceId = prefs.getString('chat_device_id') ?? const Uuid().v4();
      
      // Verify user exists on backend
      try {
        final response = await _apiService.post('/chat/users', {
          'username': username,
          'deviceId': deviceId,
        });
        _currentUser = ChatUser.fromJson(response);
      } catch (e) {
        // Check if it's a network error - don't wipe credentials if offline
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('connection') || 
            errStr.contains('network') || 
            errStr.contains('internet') ||
            errStr.contains('server')) {
           rethrow;
        }

        // If verification fails (likely 404 or invalid user), create new user
        await prefs.remove('chat_user_id');
        await _initializeUser();
        return;
      }
    }
  }

  // Connect to Socket.io
  void _connectSocket() {
    final baseUrl = _apiService.baseUrl.replaceAll('/api', '');
    
    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      debugPrint('🔌 Connected to chat server');
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Disconnected from chat server');
      notifyListeners();
    });

    _socket!.on('new_message', (data) {
      _handleNewMessage(Message.fromJson(data));
    });

    _socket!.on('user_typing', (data) {
      debugPrint('User typing: ${data['username']}');
    });

    _socket!.onError((error) {
      debugPrint('Socket error: $error');
    });
  }

  // Handle incoming message
  void _handleNewMessage(Message message) {
    if (!_messages.containsKey(message.channelId)) {
      _messages[message.channelId] = [];
    }
    
    // Check if message already exists
    final exists = _messages[message.channelId]!.any((m) => m.id == message.id);
    if (!exists) {
      _messages[message.channelId]!.add(message);
      notifyListeners();
    }
  }

  // Load all channels
  Future<void> loadChannels() async {
    try {
      final response = await _apiService.get('/chat/channels');
      _channels = (response as List)
          .map((channel) => Channel.fromJson(channel))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load channels: ${_formatError(e)}';
      notifyListeners();
    }
  }

  // Join a channel
  Future<void> joinChannel(String channelId) async {
    try {
      _currentChannelId = channelId;
      
      // Join socket room
      _socket?.emit('join_channel', channelId);
      
      // Load messages
      await loadMessages(channelId);
      
      // Mark as joined on backend
      if (_currentUser != null) {
        await _apiService.post('/chat/channels/$channelId/join', {
          'userId': _currentUser!.id,
        });
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to join channel: ${_formatError(e)}';
      notifyListeners();
    }
  }

  // Leave a channel
  Future<void> leaveChannel(String channelId) async {
    try {
      _socket?.emit('leave_channel', channelId);
      
      if (_currentUser != null) {
        await _apiService.post('/chat/channels/$channelId/leave', {
          'userId': _currentUser!.id,
        });
      }
      
      if (_currentChannelId == channelId) {
        _currentChannelId = null;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to leave channel: ${_formatError(e)}';
      notifyListeners();
    }
  }

  // Load messages for a channel
  Future<void> loadMessages(String channelId, {int limit = 50}) async {
    try {
      final response = await _apiService.get(
        '/chat/channels/$channelId/messages?limit=$limit',
      );
      
      _messages[channelId] = (response as List)
          .map((msg) => Message.fromJson(msg))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load messages: ${_formatError(e)}';
      notifyListeners();
    }
  }

  // Send a message
  Future<void> sendMessage(String channelId, String content) async {
    if (_currentUser == null || content.trim().isEmpty) return;

    try {
      _socket?.emit('send_message', {
        'channelId': channelId,
        'userId': _currentUser!.id,
        'username': _currentUser!.username,
        'content': content.trim(),
        'messageType': 'text',
      });
    } catch (e) {
      _error = 'Failed to send message: ${_formatError(e)}';
      notifyListeners();
    }
  }

  // Send typing indicator
  void sendTypingIndicator(String channelId) {
    if (_currentUser == null) return;
    
    _socket?.emit('typing', {
      'channelId': channelId,
      'userId': _currentUser!.id,
      'username': _currentUser!.username,
    });
  }

  // Create a new channel
  Future<void> createChannel({
    required String name,
    String? description,
    required String icon,
    String? emoji,
    bool isAnnouncement = false,
  }) async {
    try {
      final response = await _apiService.post('/chat/channels', {
        'name': name,
        'description': description,
        'icon': icon,
        'emoji': emoji,
        'isAnnouncement': isAnnouncement,
      });
      
      final newChannel = Channel.fromJson(response);
      _channels.add(newChannel);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create channel: ${_formatError(e)}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  // Test helper methods
  @visibleForTesting
  void setChannels(List<Channel> channels) {
    _channels = channels;
    notifyListeners();
  }

  @visibleForTesting
  void setMessages(String channelId, List<Message> messages) {
    _messages[channelId] = messages;
    notifyListeners();
  }

  @visibleForTesting
  void setCurrentChannel(String channelId) {
    _currentChannelId = channelId;
    notifyListeners();
  }

  @visibleForTesting
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @visibleForTesting
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

