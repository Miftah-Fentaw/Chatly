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
        throw Exception('Supabase not configured. Please connect from Dreamflow panel.');
      }

      final response = await _client
          .from('chats')
          .select('*, participants:users(*), last_message:messages(*)')
          .contains('participant_ids', [userId])
          .order('last_message_time', ascending: false);

      return (response as List).map((json) => ChatModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Get chats error: $e');
      return [];
    }
  }

  Future<List<MessageModel>> getChatMessages(String chatId, {int limit = 50}) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not configured. Please connect from Dreamflow panel.');
      }

      final response = await _client
          .from('messages')
          .select('*, sender:users(*)')
          .eq('chat_id', chatId)
          .order('timestamp', ascending: false)
          .limit(limit);

      final messages = (response as List)
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

  Future<MessageModel?> sendMessage(String chatId, String senderId, String content) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not configured. Please connect from Dreamflow panel.');
      }

      final message = {
        'chat_id': chatId,
        'sender_id': senderId,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'is_read': false,
      };

      final response = await _client.from('messages').insert(message).select('*, sender:users(*)').single();

      await _client.from('chats').update({
        'last_message_time': DateTime.now().toIso8601String(),
      }).eq('id', chatId);

      debugPrint('✅ Message sent');
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

    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('timestamp', ascending: true)
        .map((data) => data.map((json) => MessageModel.fromJson(json)).toList());
  }

  Future<List<UserModel>> searchUsers(String query, String currentUserId) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not configured. Please connect from Dreamflow panel.');
      }

      final response = await _client
          .from('users')
          .select()
          .neq('id', currentUserId)
          .or('username.ilike.%$query%,email.ilike.%$query%')
          .limit(20);

      return (response as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Search users error: $e');
      return [];
    }
  }

  // Future<ChatModel?> createOrGetChat(String userId1, String userId2) async {
  //   try {
  //     if (!SupabaseConfig.isInitialized) {
  //       throw Exception('Supabase not configured. Please connect from Dreamflow panel.');
  //     }

  //     final existingChats = await _client
  //         .from('chats')
  //         .select('*')
  //         .contains('participant_ids', [userId1])
  //         .contains('participant_ids', [userId2]);

  //     if (existingChats.isNotEmpty) {
  //       return ChatModel.fromJson(existingChats.first);
  //     }

  //     final newChat = {
  //       'participant_ids': [userId1, userId2],
  //       'last_message_time': DateTime.now().toIso8601String(),
  //     };

  //     final response = await _client.from('chats').insert(newChat).select().single();
  //     debugPrint('✅ Chat created');
  //     return ChatModel.fromJson(response);
  //   } catch (e) {
  //     debugPrint('❌ Create chat error: $e');
  //     return null;
  //   }
  // }




  Future<ChatModel?> createOrGetChat(String userId1, String userId2) async {
  try {
    // Step 1: Try to find existing chat
    final response = await _client.rpc(
      'find_chat_between',
      params: {'user1': userId1, 'user2': userId2},
    );

    String chatId;

    if (response != null) {
      // Existing chat found
      chatId = response as String;
      debugPrint('Found existing chat: $chatId');
    } else {
      // No existing chat → create one
      debugPrint('No existing chat, creating new one...');
      final newChat = await _client
          .from('chats')
          .insert({})
          .select()
          .single();  // This returns Map

      chatId = newChat['id'] as String;

      await _client.from('chat_participants').insert([
        {'chat_id': chatId, 'user_id': userId1},
        {'chat_id': chatId, 'user_id': userId2},
      ]);

      debugPrint('Created new chat: $chatId');
    }

    // Step 2: Always fetch full chat data with this ID
    final chatData = await _client
        .from('chats')
        .select()
        .eq('id', chatId)
        .single();

    return ChatModel.fromJson(chatData);

  } catch (e, s) {
    debugPrint('Create chat error: $e');
    debugPrint('Stack trace: $s');
    return null;
  }
}




  Future<void> markAsRead(String chatId, String userId) async {
    try {
      if (!SupabaseConfig.isInitialized) return;

      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('sender_id', userId);

      debugPrint('✅ Messages marked as read');
    } catch (e) {
      debugPrint('❌ Mark as read error: $e');
    }
  }
}
