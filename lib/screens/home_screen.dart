import 'dart:async';
import 'dart:io';
import 'package:chatapp/utils/constants.dart';

import 'package:chatapp/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chatapp/providers/chat_provider.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
   HomeScreen({super.key});

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
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 5) return '$weeks week${weeks > 1 ? 's' : ''} ago';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '$months month${months > 1 ? 's' : ''} ago';
    final years = (diff.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final posts = postProvider.posts;

    return Scaffold(
      body: Column(
        children: [
          if (!_isOnline)
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('No internet connection', style: TextStyle(color: Colors.white))),
                  ],
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Provider.of<PostProvider>(context, listen: false).refreshPosts();
              },
              child: posts.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - kToolbarHeight,
                        child: const Center(
                          child: Text(
                            'No posts available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final auth = context.read<AuthProvider>();
                                        final chatProv = context.read<ChatProvider>();
                                        final currentUserId = auth.currentUser?.id;
                                        if (!auth.isAuthenticated) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to start a chat')));
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
                                          final otherUser = UserModel(id: post.userId, username: post.username);
                                          context.push('/chat/${chat.id}', extra: otherUser);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open chat')));
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                            child: Image.asset(AppConstants.defaultAvatarUrl)
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            post.username.toUpperCase(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Text(
                                      _timeAgo(post.timestamp),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Builder(builder: (context) {
                                  const int previewMaxChars = 240;
                                  final content = post.content;
                                  final isLong = content.length > previewMaxChars;
                                  final isExpanded = _expandedPosts.contains(post.id);

                                  if (!isLong) {
                                    return Text(content, style: const TextStyle(fontSize: 14, height: 1.5));
                                  }

                                  final display = isExpanded ? content : '${content.substring(0, previewMaxChars).trim()}...';

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isExpanded) {
                                              _expandedPosts.remove(post.id);
                                            } else {
                                              _expandedPosts.add(post.id);
                                            }
                                          });
                                        },
                                        child: Text(display, style: const TextStyle(fontSize: 14, height: 1.5)),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton(
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 24), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                          onPressed: () {
                                            setState(() {
                                              if (isExpanded) {
                                                _expandedPosts.remove(post.id);
                                              } else {
                                                _expandedPosts.add(post.id);
                                              }
                                            });
                                          },
                                          child: Text(isExpanded ? 'Show less' : 'See more', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                const SizedBox(height: 12),
                                Row(
                                  children: post.reactions.entries.map((e) {
                                    final isUserReaction = post.currentUserReaction == e.key;
                                    return GestureDetector(
                                      onTap: () {
                                        final auth = context.read<AuthProvider>();
                                        if (!auth.isAuthenticated) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to react')));
                                          return;
                                        }
                                        postProvider.reactToPost(post.id, e.key);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                          border: isUserReaction
                                              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                                              : null,
                                        ),
                                        child: Row(

                                          children: [
                                            Text(
                                              e.key,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isUserReaction ? FontWeight.bold : FontWeight.normal,
                                                color: isUserReaction
                                                    ? Theme.of(context).colorScheme.primary
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              e.value.toString(),
                                              style: TextStyle(
                                                color: isUserReaction
                                                    ? Theme.of(context).colorScheme.primary
                                                    : Theme.of(context).primaryColorLight,
                                                fontSize: 13,
                                                fontWeight: isUserReaction ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkNetwork();
    _networkTimer = Timer.periodic(const Duration(seconds: 8), (_) => _checkNetwork());
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
