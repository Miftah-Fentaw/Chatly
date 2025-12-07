import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chatapp/config/supabase_client.dart';
import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';

class ChatService {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<ChatModel>> getChats(String userId) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception(
            'Supabase not configured. Please connect from Dreamflow panel.');
      }

      final response = await _client
          .from('chats')
          .select('*, participants:chat_participants(user_id:users(*))')
          .contains('participant_ids', [userId]).order('last_message_time',
              ascending: false);

      final chats =
          (response as List).map((json) => ChatModel.fromJson(json)).toList();

      // Fallback: If participants are empty (likely due to missing join table), fetch users manually
      for (var chat in chats) {
        if (chat.participants.isEmpty && chat.participantIds.isNotEmpty) {
          try {
            final usersResponse = await _client
                .from('users')
                .select()
                .inFilter('id', chat.participantIds);

            final users = (usersResponse as List)
                .map((json) => UserModel.fromJson(json))
                .toList();

            // Update the chat with fetched participants
            // Since ChatModel fields are final, we likely need to check if we can modify it
            // or if we rely on the fact that we are returning a new list.
            // Actually ChatModel has a participants field which is final.
            // We need to replace the ChatModel instance in the list.
            // But valid iteration modification is tricky.
            // Let's create a new list.
          } catch (e) {
            debugPrint('Error fetching fallback participants: $e');
          }
        }
      }

      // Better approach: Map nicely
      return await Future.wait(chats.map((chat) async {
        if (chat.participants.isEmpty && chat.participantIds.isNotEmpty) {
          try {
            final usersResponse = await _client
                .from('users')
                .select()
                .inFilter('id', chat.participantIds);

            final users = (usersResponse as List)
                .map((json) => UserModel.fromJson(json))
                .toList();

            return chat.copyWith(participants: users);
          } catch (e) {
            debugPrint(
                'Error fetching fallback participants for chat ${chat.id}: $e');
            return chat;
          }
        }
        return chat;
      }));
    } catch (e) {
      debugPrint('❌ Get chats error: $e');
      return [];
    }
  }

  Future<List<MessageModel>> getChatMessages(String chatId,
      {int limit = 50}) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception(
            'Supabase not configured. Please connect from Dreamflow panel.');
      }

      final response = await _client
          .from('messages')
          .select('*, sender:users(*)')
          .eq('chat_id', chatId)
          .order('created_at', ascending: false)
          .limit(limit);

      final messages = (response)
          .map((json) => MessageModel.fromJson(json))
          .toList()
          .reversed
          .toList();

      return messages;
    } catch (e) {
      debugPrint('❌ Get messages error: $e');
      return [];
    }
  }

  Future<MessageModel?> sendMessage(
      String chatId, String senderId, String content) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception(
            'Supabase not configured. Please connect from Dreamflow panel.');
      }

      final tableInfo = await _client.from('messages').select('*').limit(1);
      debugPrint('Messages table structure: $tableInfo');

      final message = {
        'chat_id': chatId,
        'user_id': senderId,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };

      debugPrint('Sending message with data: $message');

      final response = await _client
          .from('messages')
          .insert(message)
          .select('*, user:users!inner(*)')
          .single();

      await _client.from('chats').update({
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', chatId);

      debugPrint('✅ Message sent successfully');
      return MessageModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Send message error: $e');
      return null;
    }
  }

  Stream<List<MessageModel>> streamMessages(String chatId) {
    if (!SupabaseConfig.isInitialized) {
      return Stream.value([]);
    }

    try {
      return _client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('chat_id', chatId)
          .order('created_at', ascending: true)
          .map((data) => data
              .map((json) {
                debugPrint('Streamed message: $json');
                return MessageModel.fromJson(json);
              })
              .toList()
              .cast<MessageModel>());
    } catch (e) {
      debugPrint('Error in message stream: $e');
      return Stream.value([]);
    }
  }

  Stream<List<ChatModel>> streamUserChats(String userId) {
    return _client
        .from('chats')
        .stream(primaryKey: ['id'])
        .asyncMap((event) => getChats(userId))
        .handleError((e) {
          debugPrint('Error in user chats stream: $e');
        });
  }

  Future<void> updateChatOnNewMessage(
      String chatId, String message, String senderId) async {
    try {
      await _client.from('chats').update({
        'last_message': message,
        'last_message_sender_id': senderId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', chatId);
    } catch (e) {
      debugPrint('Error updating chat on new message: $e');
      rethrow;
    }
  }

  Future<ChatModel> createOrGetChat(String userId1, String userId2) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not configured');
      }

      final participants = [userId1, userId2]..sort();

      final response = await _client
          .from('chats')
          .select('*, participants:chat_participants(user_id:users(*))')
          .contains('participant_ids', participants)
          .limit(1);

      if (response.isNotEmpty) {
        return ChatModel.fromJson(response[0]);
      }

      final newChat = {
        'participant_ids': participants,
        'created_at': DateTime.now().toIso8601String(),
        'unread_count': 0,
      };

      final createdChat = await _client
          .from('chats')
          .insert(newChat)
          .select('*, participants:chat_participants(user_id:users(*))')
          .single();

      return ChatModel.fromJson(createdChat);
    } catch (e) {
      debugPrint('Error in createOrGetChat: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> searchUsers(
      String query, String currentUserId) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not configured');
      }

      late final List response;
      if (query.isEmpty) {
        response = await _client
            .from('users')
            .select()
            .neq('id', currentUserId)
            .order('created_at', ascending: false)
            .limit(20);
      } else {
        response = await _client
            .from('users')
            .select()
            .neq('id', currentUserId)
            .or('username.ilike.%$query%,email.ilike.%$query%')
            .limit(10);
      }

      return (response).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Search users error: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String chatId, String userId) async {
    try {
      if (!SupabaseConfig.isInitialized) return;

      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('user_id', userId);

      debugPrint('✅ Messages marked as read');
    } catch (e) {
      debugPrint('❌ Mark as read error: $e');
      rethrow;
    }
  }
}
