import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/providers/chat_provider.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/widgets/user_avatar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context
            .read<ChatProvider>()
            .loadChats(authProvider.currentUser!.id, useCache: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startNewChat(UserModel user) async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    final chat = await chatProvider.createOrGetChat(
      authProvider.currentUser!.id,
      user.id,
    );

    if (chat != null && mounted) {
      context.push('/chat/${chat.id}', extra: user);
      setState(() => _isSearching = false);
      _searchController.clear();
      chatProvider.clearSearchResults();
    } else {
      final msg = chatProvider.errorMessage ?? 'Unable to open chat.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                onChanged: (query) {
                  final authProvider = context.read<AuthProvider>();
                  context.read<ChatProvider>().searchUsers(
                        query,
                        authProvider.currentUser!.id,
                      );
                },
              )
            : const Text('Messages',
                style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<ChatProvider>().clearSearchResults();
                }
              });
            },
          ),
        ],
      ),
      body: _isSearching ? _buildSearchResults() : _buildChatList(),
      floatingActionButton: _isSearching
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              child: const Icon(Icons.edit_outlined),
            ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatProvider.searchResults.isEmpty &&
            _searchController.text.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off_outlined,
                    size: 64, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                const Text('No users found'),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: chatProvider.searchResults.length,
          separatorBuilder: (c, i) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final user = chatProvider.searchResults[index];
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading:
                  UserAvatar(user: user, radius: 24, showOnlineStatus: true),
              title: Text(user.username,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(user.email ?? '',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              onTap: () => _startNewChat(user),
            );
          },
        );
      },
    );
  }

  Widget _buildChatList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading && chatProvider.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatProvider.chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                const SizedBox(height: 20),
                Text(
                  'No messages yet',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a conversation with a friend!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final authProvider = context.read<AuthProvider>();
            await chatProvider.loadChats(
              authProvider.currentUser!.id,
              useCache: false,
            );
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chatProvider.chats.length,
            separatorBuilder: (c, i) =>
                const Divider(height: 1, indent: 84, endIndent: 16),
            itemBuilder: (context, index) {
              final chat = chatProvider.chats[index];
              final authProvider = context.read<AuthProvider>();
              final otherUser = chat.participants.firstWhere(
                (user) => user.id != authProvider.currentUser!.id,
                orElse: () => UserModel(
                  id: '',
                  email: '',
                  username: 'Unknown',
                  lastSeen: DateTime.now(),
                  createdAt: DateTime.now(),
                ),
              );

              final isUnread = chat.unreadCount > 0;
              final theme = Theme.of(context);

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: UserAvatar(
                    user: otherUser, radius: 28, showOnlineStatus: true),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        otherUser.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (chat.lastMessageTime != null)
                      Text(
                        _formatTime(chat.lastMessageTime!.toDate()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isUnread
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat.lastMessage?.content ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isUnread
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isUnread ? FontWeight.w500 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (chat.unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          chat.unreadCount > 9 ? '9+' : '${chat.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () => context.push('/chat/${chat.id}', extra: otherUser),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return DateFormat('HH:mm').format(dt);
    } else if (now.difference(dt).inDays < 7) {
      return DateFormat('E').format(dt);
    } else {
      return DateFormat('MM/dd').format(dt);
    }
  }
}
