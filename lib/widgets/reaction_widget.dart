import 'package:chatapp/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class ReactionBar extends StatelessWidget {
  final PostItem post;
  final VoidCallback? onChat;
  final VoidCallback? onShare;

  const ReactionBar({
    super.key,
    required this.post,
    this.onChat,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final postProvider = context.read<PostProvider>();
    final auth = context.read<AuthProvider>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 4),
          _buildReactionButton(
            context,
            iconPath: "assets/icons/like.png",
            iconData: Icons.favorite_rounded,
            activeIconData: Icons.favorite_rounded,
            type: "likes",
            activeColor: Colors.pink,
            count: post.reactions["likes"] ?? 0,
            isSelected: post.currentUserReaction == "likes",
            onTap: () =>
                postProvider.reactToPost(post.id, "assets/icons/like.png"),
          ),
          const SizedBox(width: 4),
          _buildReactionButton(
            context,
            iconPath: "assets/icons/dislike.png",
            iconData: Icons.thumb_down_outlined,
            activeIconData: Icons.thumb_down_rounded,
            type: "dislikes",
            activeColor: theme.colorScheme.primary,
            count: post.reactions["dislikes"] ?? 0,
            isSelected: post.currentUserReaction == "dislikes",
            onTap: () =>
                postProvider.reactToPost(post.id, "assets/icons/dislike.png"),
          ),
          const SizedBox(width: 4),
          _buildReactionButton(
            context,
            iconPath: "assets/icons/angry.png",
            iconData: Icons.mood_bad_outlined,
            activeIconData: Icons.mood_bad_rounded,
            type: "angry",
            activeColor: Colors.orange,
            count: post.reactions["angry"] ?? 0,
            isSelected: post.currentUserReaction == "angry",
            onTap: () =>
                postProvider.reactToPost(post.id, "assets/icons/angry.png"),
          ),
          const Spacer(),
          _buildActionButton(
            context,
            iconData: Icons.share_outlined,
            activeColor: theme.colorScheme.onSurfaceVariant,
            onTap: onShare,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData iconData,
    required Color activeColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          iconData,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildReactionButton(
    BuildContext context, {
    required String iconPath,
    required IconData iconData,
    required IconData activeIconData,
    required String type,
    required Color activeColor,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final auth = context.read<AuthProvider>();

    return InkWell(
      onTap: () {
        if (!auth.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to react')),
          );
          return;
        }
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIconData : iconData,
              size: 20,
              color: isSelected
                  ? activeColor
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Text(
                count.toString(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? activeColor
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
