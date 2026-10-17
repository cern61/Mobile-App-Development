import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import 'profile_avatar.dart';

/// The main profile card: avatar, name, title and contact summary.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileAvatar(user: user, radius: 50),
            const SizedBox(height: 16),
            Text(
              user.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const Divider(height: 30, thickness: 1),
            ListTile(
              leading: Icon(Icons.email, color: colors.primary),
              title: const Text('Email'),
              subtitle: Text(user.email),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: colors.primary),
              title: const Text('Phone'),
              subtitle: Text(user.phone),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: colors.primary),
              title: const Text('Location'),
              subtitle: Text(user.location),
            ),
          ],
        ),
      ),
    );
  }
}
