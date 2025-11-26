import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/config/firebase_config.dart';
import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';

/// Service class for handling chat-related operations with Firebase Firestore
class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  final String _chatsCollection = 'chats';
  final String _messagesSubcollection = 'messages';
  final String _usersCollection = 'users';

  // Singleton instance
  static final FirebaseChatService _instance = FirebaseChatService._internal();
  
  factory FirebaseChatService() => _instance;
  
  FirebaseChatService._internal();

  /// Get a stream of chats for a specific user
  Stream<List<ChatModel>> getChatsStream(String userId) {
    try {
      return _firestore
          .collection(_chatsCollection)
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final List<ChatModel> chats = [];
        
        for (var doc in snapshot.docs) {
          final chatData = doc.data();
          final participants = await _getParticipants(chatData['participantIds'] as List<dynamic>);
          
          chats.add(ChatModel(
            id: doc.id,
            participantIds: List<String>.from(chatData['participantIds'] as List<dynamic>),
            participants: participants,
            lastMessage: chatData['lastMessage'] != null 
                ? MessageModel.fromJson({
                    ...chatData['lastMessage'] as Map<String, dynamic>,
                    'id': '${doc.id}_last',
                  })
                : null,
            lastMessageTime: chatData['lastMessageTime'] as Timestamp?,
            unreadCount: (chatData['unreadCounts'] as Map<String, dynamic>?)?[userId] ?? 0,
          ));
        }
        
        return chats;
      });
    } catch (e) {
      print('Error getting chats stream: $e');
      rethrow;
    }
  }

  /// Get messages for a specific chat
  Stream<List<MessageModel>> getMessagesStream(String chatId, {int limit = 50}) {
    try {
      return _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .collection(_messagesSubcollection)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromJson({
                    ...doc.data(),
                    'id': doc.id,
                  }))
              .toList()
              .reversed
              .toList());
    } catch (e) {
      print('Error getting messages stream: $e');
      rethrow;
    }
  }

  /// Send a new message
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageRef = _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .collection(_messagesSubcollection)
          .doc();

      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: senderId,
        content: content,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        replyToMessageId: replyToMessageId,
        metadata: metadata,
      );

      // Add message to the messages subcollection
      await messageRef.set(message.toJson());

      // Update the chat's last message and timestamp
      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'lastMessage': message.toJson(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return message;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Create a new chat between users
  Future<ChatModel> createChat({
    required List<String> participantIds,
    String? initialMessage,
  }) async {
    try {
      // Sort participant IDs for consistent chat lookup
      participantIds = List.from(participantIds)..sort();
      
      // Check if chat already exists
      final existingChat = await _findExistingChat(participantIds);
      if (existingChat != null) {
        return existingChat;
      }

      // Create new chat
      final chatRef = _firestore.collection(_chatsCollection).doc();
      final now = DateTime.now();
      
      final chatData = {
        'participantIds': participantIds,
        'createdAt': now,
        'updatedAt': now,
        'unreadCounts': Map.fromIterable(
          participantIds,
          key: (id) => id,
          value: (_) => 0,
        ),
      };
      
      await chatRef.set(chatData);

      // Add initial message if provided
      if (initialMessage != null && initialMessage.isNotEmpty) {
        await sendMessage(
          chatId: chatRef.id,
          senderId: participantIds.first,
          content: initialMessage,
        );
      }

      return ChatModel(
        id: chatRef.id,
        participantIds: participantIds,
        participants: await _getParticipants(participantIds.cast<dynamic>()),
        lastMessageTime: Timestamp.fromDate(now),
        unreadCount: 0,
      );
    } catch (e) {
      print('Error creating chat: $e');
      rethrow;
    }
  }

  /// Mark messages as read for a specific user in a chat
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'unreadCounts.$userId': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking messages as read: $e');
      rethrow;
    }
  }

  /// Search for users by username or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final usernameQuery = _firestore
          .collection(_usersCollection)
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10);
      
      final emailQuery = _firestore
          .collection(_usersCollection)
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10);
      
      final results = await Future.wait([
        usernameQuery.get(),
        emailQuery.get(),
      ]);
      
      // Combine and deduplicate results
      final users = <String, UserModel>{};
      
      for (var snapshot in results) {
        for (var doc in snapshot.docs) {
          users[doc.id] = UserModel.fromJson(doc.data());
        }
      }
      
      return users.values.toList();
    } catch (e) {
      print('Error searching users: $e');
      rethrow;
    }
  }

  // Helper method to find an existing chat between participants
  Future<ChatModel?> _findExistingChat(List<String> participantIds) async {
    try {
      final snapshot = await _firestore
          .collection(_chatsCollection)
          .where('participantIds', isEqualTo: participantIds)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) return null;
      
      final doc = snapshot.docs.first;
      final data = doc.data();
      
      return ChatModel(
        id: doc.id,
        participantIds: List<String>.from(data['participantIds'] as List<dynamic>),
        participants: await _getParticipants(data['participantIds'] as List<dynamic>),
        lastMessage: data['lastMessage'] != null
            ? MessageModel.fromJson({
                ...data['lastMessage'] as Map<String, dynamic>,
                'id': '${doc.id}_last',
              })
            : null,
        lastMessageTime: data['lastMessageTime'] as Timestamp?,
        unreadCount: 0, // This will be updated by the stream
      );
    } catch (e) {
      print('Error finding existing chat: $e');
      return null;
    }
  }

  // Helper method to get user data for participants
  Future<List<UserModel>> _getParticipants(List<dynamic> participantIds) async {
    try {
      if (participantIds.isEmpty) return [];

      final participants = <UserModel>[];

      for (var id in participantIds) {
        final doc = await _firestore.collection(_usersCollection).doc(id as String).get();
        if (doc.exists) {
          participants.add(UserModel.fromJson(doc.data()!));
        }
      }

      return participants;
    } catch (e) {
      print('Error getting participants: $e');
      return [];
    }
  }
}

