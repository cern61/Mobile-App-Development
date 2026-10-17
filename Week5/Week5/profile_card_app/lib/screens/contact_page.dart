import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../widgets/page_container.dart';
import '../widgets/section_card.dart';

/// Tab 4: contact details plus a shortcut that opens the message dialog.
class ContactPage extends StatelessWidget {
  const ContactPage({
    super.key,
    required this.user,
    required this.onMessage,
  });

  final UserProfile user;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      children: [
        SectionCard(
          icon: Icons.contact_mail_outlined,
          title: 'Contact details',
          child: Column(
            children: [
              _ContactTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              const Divider(height: 1),
              _ContactTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: user.phone,
              ),
              const Divider(height: 1),
              _ContactTile(
                icon: Icons.language,
                label: 'Website',
                value: user.website,
              ),
              const Divider(height: 1),
              _ContactTile(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: user.location,
                copyable: false,
              ),
              const Divider(height: 1),
              _ContactTile(
                icon: Icons.schedule,
                label: 'Office hours',
                value: user.officeHours,
                copyable: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onMessage,
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Send a message'),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: Text(value),
      trailing: copyable
          ? IconButton(
              tooltip: 'Copy',
              icon: const Icon(Icons.copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label copied')),
                );
              },
            )
          : null,
    );
  }
}
