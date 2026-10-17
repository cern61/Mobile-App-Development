import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../widgets/page_container.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/section_card.dart';

/// Tab 2: about the user (bio, quick stats and skills).
class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageContainer(
      children: [
        Column(
          children: [
            ProfileAvatar(user: user, radius: 40),
            const SizedBox(height: 12),
            Text(
              user.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${user.experienceYears}+',
                label: 'Years',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                value: '${user.projectCount}',
                label: 'Projects',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                value: '${user.skills.length}',
                label: 'Key skills',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          icon: Icons.person_outline,
          title: 'About me',
          child: Text(
            user.bio,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          icon: Icons.bolt_outlined,
          title: 'Skills',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in user.skills) Chip(label: Text(skill)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
