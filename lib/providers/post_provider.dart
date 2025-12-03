import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/cache_service.dart';

class PostItem {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime timestamp;
  final Map<String, int> reactions;
  final String? currentUserReaction;

  PostItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
    required this.reactions,
    this.currentUserReaction,
  });
}

class PostProvider extends ChangeNotifier {
  final PostService _service = PostService();
  final CacheService _cacheService = CacheService();
  final List<PostItem> _posts = [];
  StreamSubscription<List<Post>>? _sub;

  final Map<String, Map<String, String>> _userReactions = {};

  List<PostItem> get posts => List.unmodifiable(_posts);

  PostProvider() {
    _init();
  }

  void _init() async {
    try {
      final cached = await _cacheService.getCachedPosts();
      if (cached.isNotEmpty) {
        final cachedModels = cached.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
        _setFromModelList(cachedModels);
      }
    } catch (_) {}

    try {
      final fetched = await _service.fetchPosts();
      _setFromModelList(fetched);
      try {
        await _cacheService.cachePosts(fetched);
      } catch (_) {}
    } catch (_) {
    }

    try {
      _sub = _service.getPostsStream().listen((modelList) {
        _setFromModelList(modelList);
        try {
          _cacheService.cachePosts(modelList);
        } catch (_) {}
      });
    } catch (_) {
    }
  }

  void _setFromModelList(List<Post> modelList) {
    final userId = _service.client.auth.currentUser?.id;
    _posts
      ..clear()
      ..addAll(modelList.map((m) {
        String? currentUserReaction;
        if (_userReactions[m.id] != null && userId != null) {
          currentUserReaction = _userReactions[m.id]![userId];
        }
        return PostItem(
          id: m.id,
          userId: m.userId,
          username: m.username,
          content: m.content,
          timestamp: m.createdAt,
          reactions: {
            '👍': m.likes,
            '👎': m.dislikes,
            '😡': m.angry,
          },
          currentUserReaction: currentUserReaction,
        );
      }));
    notifyListeners();
  }

  Future<void> addPost(String username, String content) async {
    await _service.createPost(content, username);
    try {
      final list = await _service.fetchPosts();
      _setFromModelList(list);
    } catch (_) {}
  }

  Future<void> refreshPosts() async {
    try {
      final list = await _service.fetchPosts();
      _setFromModelList(list);
      try {
        await _cacheService.cachePosts(list);
      } catch (_) {}
    } catch (_) {
    }
  }

  Future<void> reactToPost(String postId, String reactionEmoji) async {
    final mapping = {'👍': 'likes', '👎': 'dislikes', '😡': 'angry'};
    final column = mapping[reactionEmoji];
    if (column == null) return;
    final userId = _service.client.auth.currentUser?.id;
    if (userId == null) return;

    final current = _userReactions[postId]?[userId];
    if (current == reactionEmoji) {
      _userReactions[postId] ??= {};
      _userReactions[postId]!.remove(userId);
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        _posts[idx].reactions[reactionEmoji] = (_posts[idx].reactions[reactionEmoji] ?? 1) - 1;
      }
      notifyListeners();
      try {
        await _service.updateReaction(postId, column, -1);
      } catch (_) {}
      return;
    }

    if (current != null) {
      final prevCol = mapping[current];
      if (prevCol != null) {
        final idx = _posts.indexWhere((p) => p.id == postId);
        if (idx != -1) {
          _posts[idx].reactions[current] = (_posts[idx].reactions[current] ?? 1) - 1;
        }
        try {
          await _service.updateReaction(postId, prevCol, -1);
        } catch (_) {}
      }
    }
    _userReactions[postId] ??= {};
    _userReactions[postId]![userId] = reactionEmoji;
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      _posts[idx].reactions[reactionEmoji] = (_posts[idx].reactions[reactionEmoji] ?? 0) + 1;
    }
    notifyListeners();
    try {
      await _service.updateReaction(postId, column, 1);
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}



