import 'dart:async';
import 'dart:math' as math;

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
        final cachedModels = cached
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
        _setFromModelList(cachedModels);
      }
    } catch (_) {}

    try {
      final fetched = await _service.fetchPosts();
      _setFromModelList(fetched);
      try {
        await _cacheService.cachePosts(fetched);
      } catch (_) {}
    } catch (_) {}

    try {
      _sub = _service.getPostsStream().listen((modelList) {
        _setFromModelList(modelList);
        try {
          _cacheService.cachePosts(modelList);
        } catch (_) {}
      });
    } catch (_) {}
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
            'likes': math.max(0, m.likes),
            'dislikes': math.max(0, m.dislikes),
            'angry': math.max(0, m.angry),
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
    } catch (_) {}
  }

  Future<void> reactToPost(String postId, String reactionIcon) async {
    final iconToReactionType = {
      "assets/icons/like.png": "likes",
      "assets/icons/dislike.png": "dislikes",
      "assets/icons/angry.png": "angry",
    };

    final reactionType = iconToReactionType[reactionIcon];
    if (reactionType == null) return;

    final userId = _service.client.auth.currentUser?.id;
    if (userId == null) return;

    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];

    // Current user's reaction type for this post (e.g. 'likes')
    final currentReactionType = post.currentUserReaction;

    final newReactions = Map<String, int>.from(post.reactions);

    // If tapping the same reaction -> retract
    if (currentReactionType == reactionType) {
      newReactions[reactionType] = (newReactions[reactionType] ?? 0) - 1;
      if (newReactions[reactionType]! < 0) newReactions[reactionType] = 0;

      _userReactions[postId]?.remove(userId);

      _posts[postIndex] = PostItem(
        id: post.id,
        userId: post.userId,
        username: post.username,
        content: post.content,
        timestamp: post.timestamp,
        reactions: newReactions,
        currentUserReaction: null,
      );

      notifyListeners();

      try {
        await _service.updateReaction(postId, reactionType, -1);
      } catch (_) {}
      return;
    }

    // If switching from another reaction -> decrement previous
    if (currentReactionType != null && currentReactionType != reactionType) {
      final prevType = currentReactionType;
      newReactions[prevType] = (newReactions[prevType] ?? 0) - 1;
      if (newReactions[prevType]! < 0) newReactions[prevType] = 0;

      try {
        await _service.updateReaction(postId, prevType, -1);
      } catch (_) {}
    }

    // Add new reaction
    newReactions[reactionType] = (newReactions[reactionType] ?? 0) + 1;

    _userReactions[postId] ??= {};
    _userReactions[postId]![userId] = reactionType;

    _posts[postIndex] = PostItem(
      id: post.id,
      userId: post.userId,
      username: post.username,
      content: post.content,
      timestamp: post.timestamp,
      reactions: newReactions,
      currentUserReaction: reactionType,
    );

    notifyListeners();

    try {
      await _service.updateReaction(postId, reactionType, 1);
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
