import 'dart:async';
import 'dart:io';
import 'package:chatapp/providers/post_provider.dart';
import 'package:chatapp/widgets/reaction_widget.dart';
import 'package:chatapp/widgets/user_avatar.dart'; // Ensure this is imported
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chatapp/providers/chat_provider.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _expandedPosts = {};
  bool _isOnline = true;
  Timer? _networkTimer;

  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final posts = postProvider.posts;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          if (!_isOnline)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.wifi_off, color: theme.colorScheme.error),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<PostProvider>(context, listen: false)
              .refreshPosts();
        },
        child: posts.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feed_outlined,
                            size: 64,
                            color: theme.colorScheme.outline.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share something!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPostCard(context, post);
                },
              ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, dynamic post) {
    final theme = Theme.of(context);
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.currentUser?.id;

    // Use a placeholder user object for Avatar until we have real user data object in post
    final postUser = UserModel(
        id: post.userId,
        username: post.username,
        email: "",
        createdAt: DateTime.now());

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _handleUserTap(context, post),
                  child: UserAvatar(
                    user: postUser,
                    radius: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () => _handleUserTap(context, post),
                              child: Text(
                                post.username,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '·',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _timeAgo(post.timestamp),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (currentUserId != post.userId)
                  IconButton(
                    icon: Icon(Icons.more_horiz,
                        size: 20, color: theme.colorScheme.onSurfaceVariant),
                    onPressed: () {
                      // Options logic
                    },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Builder(builder: (context) {
              const int previewMaxChars = 280; // Standard X character limit
              final content = post.content as String;
              final isLong = content.length > previewMaxChars;
              final isExpanded = _expandedPosts.contains(post.id);

              if (!isLong) {
                return Text(content,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.4));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpanded
                        ? content
                        : '${content.substring(0, previewMaxChars).trim()}...',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedPosts.remove(post.id);
                        } else {
                          _expandedPosts.add(post.id);
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isExpanded ? 'Show less' : 'Read more',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              );
            }),
          ),

          // Actions (Reactions)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          ReactionBar(
            post: post,
            onChat: () => _handleChatTap(context, post),
            onShare: () {
              // Share implementation
            },
          ),
        ],
      ),
    );
  }

  void _handleUserTap(BuildContext context, dynamic post) {
    // Navigate to user profile if available, or just ignore for now if not implemented
    // For now, standard behavior is maybe view profile.
    // Implementing this requires a route like /profile/:userId
  }

  Future<void> _handleChatTap(BuildContext context, dynamic post) async {
    final auth = context.read<AuthProvider>();
    final chatProv = context.read<ChatProvider>();
    final currentUserId = auth.currentUser?.id;

    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to start a chat')),
      );
      return;
    }
    if (currentUserId == null) return;
    if (currentUserId == post.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself')),
      );
      return;
    }

    final chat = await chatProv.createOrGetChat(currentUserId, post.userId);
    if (chat != null) {
      final otherUser = UserModel(
          id: post.userId,
          username: post.username,
          email: "",
          createdAt: DateTime.now());
      if (mounted) context.push('/chat/${chat.id}', extra: otherUser);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open chat')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkNetwork();
    _networkTimer =
        Timer.periodic(const Duration(seconds: 8), (_) => _checkNetwork());
  }

  @override
  void dispose() {
    _networkTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (mounted && online != _isOnline) setState(() => _isOnline = online);
    } catch (_) {
      if (mounted && _isOnline) setState(() => _isOnline = false);
    }
  }
}
