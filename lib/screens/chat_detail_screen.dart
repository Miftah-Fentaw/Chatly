import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/providers/chat_provider.dart';
import 'package:chatapp/widgets/chat_bubble.dart';
import 'package:chatapp/widgets/custom_appbar.dart';
import 'package:chatapp/widgets/message_input.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final UserModel otherUser;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ChatProvider _chatProvider;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _chatProvider = context.read<ChatProvider>();
      _chatProvider.loadMessages(widget.chatId);
      _chatProvider.subscribeToMessages(widget.chatId);

      final authProvider = context.read<AuthProvider>();
      _chatProvider.markAsRead(widget.chatId, authProvider.currentUser!.id);

      _isInit = true;
    }
  }

  @override
  void dispose() {
    _chatProvider.unsubscribeFromMessages();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String content) {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendMessage(
      widget.chatId,
      authProvider.currentUser!.id,
      content,
      context: context,
    );

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    // The theme controls the background now (defined in theme.dart as scaffoldBackgroundColor),
    // but for chat specifically we might want a slightly different background or a pattern.
    // For a modern "Telegram/Twitter" look, the solid theme background is usually fine.

    return Scaffold(
      // CustomAppBar needs to be checked/updated or replaced with standard AppBar if it's too legacy.
      // Assuming CustomAppBar provides the profile info.
      appBar: CustomAppBar(
        user: widget.otherUser,
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
            tooltip: 'Video Call',
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {},
            tooltip: 'Audio Call',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 12),
                    Text('View profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete chat', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoadingMessages &&
                    chatProvider.currentMessages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatProvider.currentMessages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Say hello to ${widget.otherUser.username}!',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  itemCount: chatProvider.currentMessages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.currentMessages[index];
                    final authProvider = context.read<AuthProvider>();
                    final isSent =
                        message.senderId == authProvider.currentUser!.id;

                    return ChatBubble(
                      message: message,
                      isSent: isSent,
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
