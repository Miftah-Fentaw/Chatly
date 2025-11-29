import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/services/chat_service.dart';
import 'package:chatapp/services/cache_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final CacheService _cacheService = CacheService();

  List<ChatModel> _chats = [];
  List<MessageModel> _currentMessages = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  bool _isSearching = false;
  String? _errorMessage;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _chatsSubscription;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentMessages => _currentMessages;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  void setupChatUpdates(String userId) {
    _chatsSubscription?.cancel();
    _chatsSubscription = _chatService.streamUserChats(userId).listen(
      (chats) {
        _chats = chats;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Error receiving chat updates: $e';
        debugPrint(_errorMessage);
      },
    );
  }

  Future<void> loadChats(String userId, {bool useCache = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (useCache) {
        _chats = await _cacheService.getCachedChats();
        if (_chats.isNotEmpty) notifyListeners();
      }

      final chats = await _chatService.getChats(userId);
      _chats = chats;
      await _cacheService.cacheChats(chats);
      notifyListeners(); // Notify after getting fresh data

      // Set up real-time updates
      setupChatUpdates(userId);
    } catch (e) {
      _errorMessage = 'Failed to load chats: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String chatId, {bool useCache = true}) async {
    _isLoadingMessages = true;
    notifyListeners();

    try {
      if (useCache) {
        _currentMessages = await _cacheService.getCachedMessages(chatId);
        notifyListeners();
      }

      final messages = await _chatService.getChatMessages(chatId);
      _currentMessages = messages;
      await _cacheService.cacheMessages(chatId, messages);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Load messages error: $e');
    }

    _isLoadingMessages = false;
    notifyListeners();
  }

  void subscribeToMessages(String chatId) {
    _messageSubscription?.cancel();
    _messageSubscription = _chatService.streamMessages(chatId).listen((messages) {
      _currentMessages = messages;
      notifyListeners();
    });
  }

  void unsubscribeFromMessages() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  Future<void> sendMessage(String chatId, String senderId, String content, {BuildContext? context}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Send the message
      final message = await _chatService.sendMessage(chatId, senderId, content);
      
      if (message != null) {
        _currentMessages.add(message);
        
        // Update the chat's last message
        await updateChatOnNewMessage(chatId, content, senderId);
        
        // Update the chat in the chats list if it exists
        final chatIndex = _chats.indexWhere((c) => c.id == chatId);
        if (chatIndex != -1) {
          final updatedChat = _chats[chatIndex].copyWith(
            lastMessage: message,
            lastMessageTime: Timestamp.now(),
          );
          _chats[chatIndex] = updatedChat;
          // Move to top of the list
          final chat = _chats.removeAt(chatIndex);
          _chats.insert(0, chat);
        }
        
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to send message: ${e.toString()}';
      debugPrint('Send message error: $_errorMessage');
      
      // Show error to user if context is provided
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query, String currentUserId) async {
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _chatService.searchUsers(query, currentUserId);
    } catch (e) {
      _searchResults = [];
      _errorMessage = e.toString();
      debugPrint('Search users error: $e');
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<ChatModel?> createOrGetChat(String userId1, String userId2) async {
    try {
      _isLoading = true;
      notifyListeners();

      final chat = await _chatService.createOrGetChat(userId1, userId2);

      // Reload chats to ensure the new chat is included with all details
      await loadChats(userId1, useCache: false);
      
      _errorMessage = null;
      return chat;
    } catch (e) {
      _errorMessage = 'Failed to create chat: ${e.toString()}';
      debugPrint(_errorMessage);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String chatId, String userId) async {
    try {
      await _chatService.markAsRead(chatId, userId);
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _currentMessages = [];
    notifyListeners();
  }

  /// Clear the current search results.
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  Future<void> updateChatOnNewMessage(String chatId, String message, String senderId) async {
    try {
      await _chatService.updateChatOnNewMessage(chatId, message, senderId);
    } catch (e) {
      _errorMessage = 'Failed to update chat: ${e.toString()}';
      debugPrint(_errorMessage);
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _chatsSubscription?.cancel();
    super.dispose();
  }
}
