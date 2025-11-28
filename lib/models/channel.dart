class Channel {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String? emoji;
  final int memberCount;
  final bool isAnnouncement;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Channel({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    this.emoji,
    required this.memberCount,
    required this.isAnnouncement,
    required this.createdAt,
    this.updatedAt,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String,
      emoji: json['emoji'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      isAnnouncement: (json['is_announcement'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'emoji': emoji,
      'member_count': memberCount,
      'is_announcement': isAnnouncement ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Channel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? emoji,
    int? memberCount,
    bool? isAnnouncement,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      emoji: emoji ?? this.emoji,
      memberCount: memberCount ?? this.memberCount,
      isAnnouncement: isAnnouncement ?? this.isAnnouncement,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

