import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/widgets/user_avatar.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSent;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sent messages: Primary color (vivid blue) with white text
    // Received messages: Surface variant/Container (light grey/dark grey) with onSurface text
    final bubbleColor =
        isSent ? colorScheme.primary : colorScheme.surfaceContainerHighest;

    final textColor = isSent ? colorScheme.onPrimary : colorScheme.onSurface;

    final timeColor = isSent
        ? colorScheme.onPrimary.withOpacity(0.7)
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) ...[
            UserAvatar(user: message.sender, radius: 14),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isSent ? 20 : 4),
                  bottomRight: Radius.circular(isSent ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: timeColor,
                        ),
                      ),
                      if (isSent) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead ? Colors.white : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSent) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
