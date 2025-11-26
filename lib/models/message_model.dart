import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/user_model.dart';

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final UserModel? sender;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageStatus status;
  final String? replyToMessageId;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.sender,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.status = MessageStatus.sent,
    this.replyToMessageId,
    this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      chatId: json['chat_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      sender: json['sender'] != null
          ? UserModel.fromJson(Map<String, dynamic>.from(json['sender']))
          : null,
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      status: json['status'] != null
          ? MessageStatus.values.firstWhere(
              (e) => e.toString() == 'MessageStatus.${json['status']}',
              orElse: () => MessageStatus.sent,
            )
          : MessageStatus.sent,
      replyToMessageId: json['reply_to_message_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'sender': sender?.toJson(),
      'content': content,
      'timestamp': timestamp,
      'is_read': isRead,
      'status': status.toString().split('.').last,
      'reply_to_message_id': replyToMessageId,
      'metadata': metadata,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    UserModel? sender,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageStatus? status,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, chatId: $chatId, senderId: $senderId, content: $content)';
  }
}
