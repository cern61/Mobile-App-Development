import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../widgets/page_container.dart';
import '../widgets/section_card.dart';

/// Tab 3: mission, vision and core values.
class MissionVisionPage extends StatelessWidget {
  const MissionVisionPage({super.key, required this.user});

  final UserProfile user;

  static const List<String> _coreValues = [
    'Curiosity',
    'Quality',
    'Collaboration',
    'Integrity',
  ];

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.5,
        );

    return PageContainer(
      children: [
        SectionCard(
          icon: Icons.flag_outlined,
          title: 'Mission',
          child: Text(user.mission, style: bodyStyle),
        ),
        const SizedBox(height: 16),
        SectionCard(
          icon: Icons.visibility_outlined,
          title: 'Vision',
          child: Text(user.vision, style: bodyStyle),
        ),
        const SizedBox(height: 16),
        SectionCard(
          icon: Icons.favorite_border,
          title: 'Core values',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in _coreValues) Chip(label: Text(value)),
            ],
          ),
        ),
      ],
    );
  }
}
