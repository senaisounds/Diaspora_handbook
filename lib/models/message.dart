class Message {
  final String id;
  final String channelId;
  final String userId;
  final String username;
  final String content;
  final String messageType;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.channelId,
    required this.userId,
    required this.username,
    required this.content,
    this.messageType = 'text',
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      channelId: json['channel_id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'user_id': userId,
      'username': username,
      'content': content,
      'message_type': messageType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isSystemMessage => userId == 'system';
}

class ChatUser {
  final String id;
  final String username;
  final String deviceId;
  final DateTime createdAt;

  ChatUser({
    required this.id,
    required this.username,
    required this.deviceId,
    required this.createdAt,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as String,
      username: json['username'] as String,
      deviceId: json['device_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'device_id': deviceId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

