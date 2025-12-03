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
        context.read<ChatProvider>().loadChats(authProvider.currentUser!.id, useCache: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (_isSearching) {
      chatProvider.searchUsers('', authProvider.currentUser!.id);
    } else {
      _searchController.clear();
      chatProvider.clearSearchResults();
    }
  }

  Future<void> _startNewChat(UserModel user) async {
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
    } else {
      final msg = chatProvider.errorMessage ?? 'Unable to open chat. Please try again.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
            : Text(
                'messages',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),


        ],
      ),
      body: _isSearching ? _buildSearchResults() : _buildChatList(),
      floatingActionButton: _isSearching
          ? null
          : FloatingActionButton(
              onPressed: _toggleSearch,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person_add, color: Colors.white),
            ),

    );
  }

  Widget _buildSearchResults() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatProvider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chatProvider.searchResults.length,
          itemBuilder: (context, index) {
            final user = chatProvider.searchResults[index];
            return ListTile(
              leading: UserAvatar(
                user: user,
                radius: 24,
                showOnlineStatus: true,
              ),
              title: Text(
                user.username,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(user.email!),
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
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No chats yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to start a new chat',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
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
          child: ListView.builder(
            itemCount: chatProvider.chats.length,
            itemBuilder: (context, index) {
              final chat = chatProvider.chats[index];
              final authProvider = context.read<AuthProvider>();
              final otherUser = chat.participants.firstWhere(
                (user) => user.id != authProvider.currentUser!.id,
                orElse: () => UserModel(
                  id: '',
                  email: '',
                  username: '',
                  lastSeen: DateTime.now(),
                  createdAt: DateTime.now(),
                ),
              );

              return ListTile(
                leading: UserAvatar(
                  user: otherUser,
                  radius: 24,
                  showOnlineStatus: true,
                ),
                title: Text(
                  otherUser.username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  chat.lastMessage?.content ?? 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chat.lastMessageTime != null)
                      Text(
                        DateFormat('HH:mm').format(chat.lastMessageTime!.toDate()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (chat.unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${chat.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
}
