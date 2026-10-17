import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../widgets/profile_card.dart';

/// Tab 1: the profile card.
///
/// Conditional rendering: spinner while loading, a message if there is no
/// data, otherwise the card. The state itself lives in the parent
/// (HomeShell), so all tabs share the same user.
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.user,
    required this.isLoading,
  });

  final UserProfile? user;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final current = user;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            // Keeps the card vertically centered when there is enough room.
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                // Extra bottom padding so the floating buttons never cover the card.
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading
                        ? const _LoadingIndicator(key: ValueKey('loading'))
                        : current == null
                            ? const Text('No data found.', key: ValueKey('empty'))
                            : ProfileCard(
                                key: ValueKey(current.email),
                                user: current,
                              ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Loading profile...'),
      ],
    );
  }
}
