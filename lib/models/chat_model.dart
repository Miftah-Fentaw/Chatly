import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    try {
      Timestamp? parseTimestamp(dynamic timestamp) {
        if (timestamp == null) return null;
        if (timestamp is Timestamp) return timestamp;
        if (timestamp is String) {
          try {
            return Timestamp.fromDate(DateTime.parse(timestamp));
          } catch (e) {
            debugPrint('Error parsing timestamp: $e');
            return null;
          }
        }
        if (timestamp is DateTime) return Timestamp.fromDate(timestamp);
        return null;
      }

      List<String> parseParticipantIds(dynamic data) {
        if (data == null) return [];
        if (data is List) {
          return data.map((e) => e.toString()).toList();
        }
        return [];
      }

      List<UserModel> parseParticipants(dynamic data) {
        if (data == null) return [];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((e) => UserModel.fromJson(e))
              .toList();
        }
        return [];
      }

      MessageModel? parseLastMessage(dynamic data) {
        if (data == null) return null;

        if (data is Map<String, dynamic>) {
          try {
            return MessageModel.fromJson(data);
          } catch (e) {
            debugPrint('Error parsing last message object: $e');
            return null;
          }
        }

        if (data is String) {
          try {
            final ts = parseTimestamp(
              json['last_message_time'] ?? json['updated_at'] ?? json['lastMessageTime'],
            );

            return MessageModel(
              id: '',
              chatId: (json['id'] ?? '').toString(),
              senderId: (json['last_message_sender_id'] ?? json['lastMessageSenderId'] ?? '') as String,
              content: data,
              timestamp: ts?.toDate() ?? DateTime.now(),
            );
          } catch (e) {
            debugPrint('Error building last message from scalar: $e');
            return null;
          }
        }

        return null;
      }

      return ChatModel(
        id: (json['id'] ?? '').toString(),
        participantIds: parseParticipantIds(json['participant_ids'] ?? json['participantIds']),
        participants: parseParticipants(json['participants']),
        lastMessage: parseLastMessage(json['last_message'] ?? json['lastMessage']),
        lastMessageTime: parseTimestamp(
          json['last_message_time'] ??
          json['lastMessageTime'] ??
          json['updated_at'] ??
          json['lastMessageSentAt']
        ),
        unreadCount: (json['unread_count'] ?? json['unreadCount'] ?? 0) as int,
      );
    } catch (e) {
      debugPrint('Error parsing ChatModel: $e');
      rethrow;
    }
  }

  factory ChatModel.fromDocument(DocumentSnapshot doc) {
    return ChatModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'participants': participants.map((e) => e.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
    };
  }

  ChatModel copyWith({
    String? id,
    List<String>? participantIds,
    List<UserModel>? participants,
    MessageModel? lastMessage,
    Timestamp? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}