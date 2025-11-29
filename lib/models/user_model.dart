import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String? email;
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
  try {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? 'Unknown User',
      avatarUrl: json['avatar_url']?.toString(),
      isOnline: json['is_online'] == true,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'].toString())
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      isGuest: false,
    );
  } catch (e) {
    debugPrint('Error parsing UserModel: $e\nJSON: $json');
    return UserModel(
      id: 'error',
      email: 'error@example.com',
      username: 'Error User',
      isGuest: true,
    );
  }
}

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
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