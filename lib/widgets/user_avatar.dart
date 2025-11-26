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
    
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(avatarUrl),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        if (showOnlineStatus && user?.isOnline == true)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
