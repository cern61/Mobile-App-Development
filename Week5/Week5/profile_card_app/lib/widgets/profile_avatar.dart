import 'package:flutter/material.dart';

import '../models/user_profile.dart';

/// Circular avatar that loads the user's photo from the network.
///
/// While the image is loading (or if it fails, e.g. no internet) the user's
/// initials are shown instead, so the UI never looks broken.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.user, this.radius = 50});

  final UserProfile user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      foregroundImage: NetworkImage(user.avatarUrl),
      // Swallow image errors: the initials below stay visible as a fallback.
      onForegroundImageError: (error, stackTrace) {},
      child: Text(
        user.initials,
        style: TextStyle(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }
}
