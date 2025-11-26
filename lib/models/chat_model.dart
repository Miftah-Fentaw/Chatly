import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participantIds;
  final List<UserModel> participants;
  final MessageModel? lastMessage;
  final Timestamp? lastMessageTime;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.participantIds,
    this.participants = const [],
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  // lib/models/chat_model.dart  ← ONLY CHANGE THIS FACTORY

factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
  id: json['id'] as String? ?? '', // safe fallback
  participantIds: _safeList<String>(json['participant_ids']),
  participants: _safeUserList(json['participants']),
  lastMessage: json['last_message'] != null
      ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
      : null,
  lastMessageTime: _safeTimestamp(json['last_message_time'] ?? json['last_message_sent_at']),
  unreadCount: json['unread_count'] as int? ?? 0,
);

// ADD THESE TWO HELPER METHODS AT THE BOTTOM OF THE CLASS
static List<T> _safeList<T>(dynamic data) {
  if (data == null) return [];
  if (data is List) return data.cast<T>();
  return [];
}

static List<UserModel> _safeUserList(dynamic data) {
  if (data == null) return [];
  if (data is List) {
    return data
        .where((e) => e is Map<String, dynamic>)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }
  return [];
}

static Timestamp? _safeTimestamp(dynamic data) {
  if (data == null) return null;
  if (data is Timestamp) return data;
  if (data is String) {
    try {
      return Timestamp.fromDate(DateTime.parse(data));
    } catch (_) {
      return null;
    }
  }
  return null;
}

  factory ChatModel.fromDocument(DocumentSnapshot doc) => ChatModel(
    id: doc.id,
    participantIds: (doc['participant_ids'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    participants: doc['participants'] != null
        ? (doc['participants'] as List<dynamic>)
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : [],
    lastMessage: doc['last_message'] != null
        ? MessageModel.fromJson(doc['last_message'] as Map<String, dynamic>)
        : null,
    lastMessageTime: doc['last_message_time'] != null
        ? doc['last_message_time'] as Timestamp
        : null,
    unreadCount: doc['unread_count'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'participant_ids': participantIds,
    'participants': participants.map((e) => e.toJson()).toList(),
    'last_message': lastMessage?.toJson(),
    'last_message_time': lastMessageTime,
    'unread_count': unreadCount,
  };

  ChatModel copyWith({
    String? id,
    List<String>? participantIds,
    List<UserModel>? participants,
    MessageModel? lastMessage,
    Timestamp? lastMessageTime,
    int? unreadCount,
  }) => ChatModel(
    id: id ?? this.id,
    participantIds: participantIds ?? this.participantIds,
    participants: participants ?? this.participants,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    unreadCount: unreadCount ?? this.unreadCount,
  );
}
