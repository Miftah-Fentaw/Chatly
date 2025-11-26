// class UserModel {
//   final String id;
//   final String email;
//   final String username;
//   final String? avatarUrl;
//   final bool isOnline;
//   final DateTime lastSeen;
//   final DateTime createdAt;
//   final bool isGuest;

//   UserModel({
//     required this.id,
//     required this.email,
//     required this.username,
//     this.avatarUrl,
//     this.isOnline = false,
//     DateTime? lastSeen,
//     DateTime? createdAt,
//     this.isGuest = false,
//   })  : lastSeen = lastSeen ?? DateTime.now(),
//         createdAt = createdAt ?? DateTime.now();

//   // Create a guest user
//   factory UserModel.guest() {
//     final now = DateTime.now();
//     return UserModel(
//       id: 'guest_${now.millisecondsSinceEpoch}',
//       email: 'guest@example.com',
//       username: 'Guest User',
//       isOnline: false,
//       isGuest: true,
//     );
//   }

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'] as String,
//       email: json['email'] as String? ?? '',
//       username: json['username'] as String? ?? 'Unknown User',
//       avatarUrl: json['avatar_url'] as String?,
//       isOnline: json['is_online'] as bool? ?? false,
//       lastSeen: json['last_seen'] != null
//           ? (json['last_seen'] is DateTime
//               ? json['last_seen'] as DateTime
//               : DateTime.parse(json['last_seen'] as String))
//           : DateTime.now(),
//       createdAt: json['created_at'] != null
//           ? (json['created_at'] is DateTime
//               ? json['created_at'] as DateTime
//               : DateTime.parse(json['created_at'] as String))
//           : DateTime.now(),
//       isGuest: json['is_guest'] as bool? ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'email': email,
//         'username': username,
//         'avatar_url': avatarUrl,
//         'is_online': isOnline,
//         'last_seen': lastSeen.toIso8601String(),
//         'created_at': createdAt.toIso8601String(),
//         'is_guest': isGuest,
//       };

//   UserModel copyWith({
//     String? id,
//     String? email,
//     String? username,
//     String? avatarUrl,
//     bool? isOnline,
//     DateTime? lastSeen,
//     DateTime? createdAt,
//     bool? isGuest,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       email: email ?? this.email,
//       username: username ?? this.username,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//       isOnline: isOnline ?? this.isOnline,
//       lastSeen: lastSeen ?? this.lastSeen,
//       createdAt: createdAt ?? this.createdAt,
//       isGuest: isGuest ?? this.isGuest,
//     );
//   }

//   @override
//   String toString() {
//     return 'UserModel(id: $id, email: $email, username: $username, isGuest: $isGuest)';
//   }
// }







// models/user_model.dart
class UserModel {
  final String id;
  final String? email;        // ← now nullable, comes from auth
  final String username;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;
  final bool isGuest;

  UserModel({
    required this.id,
    this.email,
    required this.username,
    this.avatarUrl,
    this.isOnline = false,
    DateTime? lastSeen,
    DateTime? createdAt,
    this.isGuest = false,
  })  : lastSeen = lastSeen ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  factory UserModel.guest({String? username}) {
    final now = DateTime.now();
    return UserModel(
      id: 'guest-${now.millisecondsSinceEpoch}',
      email: 'guest@local',
      username: username ?? 'Guest ${now.millisecondsSinceEpoch % 1000}',
      isGuest: true,
      isOnline: true,
    );
  }

  // This is used for real users: profile data + email from auth
  factory UserModel.fromProfileMap(
    Map<String, dynamic> json, {
    required String? email,
  }) {
    return UserModel(
      id: json['id'] as String,
      email: email,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isOnline: (json['is_online'] as bool?) ?? false,
      lastSeen: _parseDate(json['last_seen']) ?? DateTime.now(),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      isGuest: false,
    );
  }

  // For loading guest from SharedPreferences
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: _parseDate(json['last_seen']) ?? DateTime.now(),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      isGuest: json['is_guest'] as bool? ?? true,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        // DON'T include email here!
        'username': username,
        'avatar_url': avatarUrl,
        'is_online': isOnline,
        'last_seen': lastSeen.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'is_guest': isGuest,
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    bool? isGuest,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}