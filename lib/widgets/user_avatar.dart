import 'package:flutter/material.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/utils/constants.dart';

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double radius;
  final bool showOnlineStatus;

  const UserAvatar({
    super.key,
    this.user,
    this.radius = 20,
    this.showOnlineStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl ?? AppConstants.defaultAvatarUrl;
    final theme = Theme.of(context);
    final size = radius * 2;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(radius * 0.8), // Squircle-ish
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (showOnlineStatus && user?.isOnline == true)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50), // Vibrant Green
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
