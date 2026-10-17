import 'package:flutter/material.dart';

import '../models/user_profile.dart';

/// Conditional rendering helper shared by the tabs.
///
/// Shows a spinner while the user is loading, a message when there is no
/// data, and otherwise builds the real page content.
class UserStateView extends StatelessWidget {
  const UserStateView({
    super.key,
    required this.isLoading,
    required this.user,
    required this.builder,
  });

  final bool isLoading;
  final UserProfile? user;
  final Widget Function(BuildContext context, UserProfile user) builder;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final current = user;
    if (current == null) {
      return const Center(child: Text('No data found.'));
    }

    return builder(context, current);
  }
}
