import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/models/message_model.dart';

class CacheService {
  static const String _chatsKey = 'cached_chats';
  static const String _postsKey = 'cached_posts';
  static const String _messagesKeyPrefix = 'cached_messages_';

  Future<void> cacheChats(List<ChatModel> chats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatsJson = chats.map((chat) => chat.toJson()).toList();
      await prefs.setString(_chatsKey, jsonEncode(chatsJson));
      debugPrint('✅ Cached ${chats.length} chats');
    } catch (e) {
      debugPrint('❌ Failed to cache chats: $e');
    }
  }

  Future<List<ChatModel>> getCachedChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatsString = prefs.getString(_chatsKey);
      if (chatsString == null) return [];
      
      final List<dynamic> chatsList = jsonDecode(chatsString);
      return chatsList.map((json) => ChatModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to get cached chats: $e');
      return [];
    }
  }

  Future<void> cacheMessages(String chatId, List<MessageModel> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((msg) => msg.toJson()).toList();
      await prefs.setString('$_messagesKeyPrefix$chatId', jsonEncode(messagesJson));
      debugPrint('✅ Cached ${messages.length} messages for chat $chatId');
    } catch (e) {
      debugPrint('❌ Failed to cache messages: $e');
    }
  }

  Future<void> cachePosts(List posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = posts
          .map((p) => p is Map ? p : (p as dynamic).toCacheJson())
          .toList();
      await prefs.setString(_postsKey, jsonEncode(postsJson));
      debugPrint('✅ Cached ${postsJson.length} posts');
    } catch (e) {
      debugPrint('❌ Failed to cache posts: $e');
    }
  }

  Future<List> getCachedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsString = prefs.getString(_postsKey);
      if (postsString == null) return [];

      final List<dynamic> postsList = jsonDecode(postsString);
      return postsList;
    } catch (e) {
      debugPrint('❌ Failed to get cached posts: $e');
      return [];
    }
  }

  Future<List<MessageModel>> getCachedMessages(String chatId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString('$_messagesKeyPrefix$chatId');
      if (messagesString == null) return [];
      
      final List<dynamic> messagesList = jsonDecode(messagesString);
      return messagesList.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to get cached messages: $e');
      return [];
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) =>
        key.startsWith(_chatsKey) || key.startsWith(_messagesKeyPrefix) || key.startsWith(_postsKey)
      ).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      debugPrint('✅ Cache cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear cache: $e');
    }
  }
}
