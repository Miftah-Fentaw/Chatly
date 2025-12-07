import 'package:chatapp/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class ReactionBar extends StatelessWidget {
  final PostItem post;

  const ReactionBar({super.key, required this.post});

  static const _reactionKeys = [
    "assets/icons/like.png",
    "assets/icons/dislike.png",
    "assets/icons/angry.png",
  ];

  static const _iconToType = {
    "assets/icons/like.png": "likes",
    "assets/icons/dislike.png": "dislikes",
    "assets/icons/angry.png": "angry",
  };



  @override
  Widget build(BuildContext context) {
    final postProvider = context.read<PostProvider>();
    final auth = context.read<AuthProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_reactionKeys.length, (index) {
          final String iconPath = _reactionKeys[index];
          final reactionType = _iconToType[iconPath]!;
          final int count = post.reactions[reactionType] ?? 0;
          final bool isSelected = post.currentUserReaction == reactionType;

          return GestureDetector(
              onTap: () {
              if (!auth.isAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please sign in to react')),
                );
                return;
              }

              postProvider.reactToPost(post.id, iconPath);
            },

            // Reaction buttons 
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2,)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    iconPath,
                    width: isSelected ? 20 : 15,
                    height: isSelected ? 25 : 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}