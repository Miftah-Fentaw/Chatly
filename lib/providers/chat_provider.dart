import 'dart:async';
import 'package:flutter/foundation.dart';
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
  bool _isTyping = false;
  String? _errorMessage;
  StreamSubscription? _messageSubscription;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentMessages => _currentMessages;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSearching => _isSearching;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;

  Future<void> loadChats(String userId, {bool useCache = true}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (useCache) {
        _chats = await _cacheService.getCachedChats();
        notifyListeners();
      }

      final chats = await _chatService.getChats(userId);
      _chats = chats;
      await _cacheService.cacheChats(chats);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Load chats error: $e');
    }

    _isLoading = false;
    notifyListeners();
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

  Future<void> sendMessage(String chatId, String senderId, String content) async {
    try {
      final message = await _chatService.sendMessage(chatId, senderId, content);
      if (message != null) {
        _currentMessages.add(message);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Send message error: $e');
    }
  }

  Future<void> searchUsers(String query, String currentUserId) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _chatService.searchUsers(query, currentUserId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Search users error: $e');
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<ChatModel?> createOrGetChat(String userId1, String userId2) async {
    try {
      return await _chatService.createOrGetChat(userId1, userId2);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Create chat error: $e');
      return null;
    }
  }

  Future<void> markAsRead(String chatId, String userId) async {
    try {
      await _chatService.markAsRead(chatId, userId);
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _currentMessages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
