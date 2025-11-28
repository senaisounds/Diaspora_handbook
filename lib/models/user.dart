class User {
  final String id;
  final String username;
  final String? email;
  final String? avatarUrl;
  final String? instagramHandle;
  final String? habeshaStatus;

  User({
    required this.id,
    required this.username,
    this.email,
    this.avatarUrl,
    this.instagramHandle,
    this.habeshaStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      instagramHandle: json['instagram_handle'],
      habeshaStatus: json['habesha_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'instagram_handle': instagramHandle,
      'habesha_status': habeshaStatus,
    };
  }
}
