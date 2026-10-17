import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../widgets/message_dialog.dart';
import '../widgets/user_state_view.dart';
import 'about_page.dart';
import 'contact_page.dart';
import 'mission_vision_page.dart';
import 'profile_page.dart';

/// App shell: owns the shared state (current user + loading flag), the
/// bottom navigation bar and the floating action buttons.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const List<String> _titles = [
    'Profile Card',
    'About',
    'Mission & Vision',
    'Contact',
  ];

  final UserService _userService = UserService();

  int _selectedIndex = 0;
  bool _isLoading = false;
  UserProfile? _user;

  @override
  void initState() {
    super.initState();
    _fetchUser(); // Load the user as soon as the app opens.
  }

  // Asynchronous data fetching (Future + async / await).
  Future<void> _fetchUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userService.fetchUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load the user. Try again.')),
      );
    }
  }

  Future<void> _openMessageDialog() async {
    final user = _user;
    if (user == null) return;

    final result = await showDialog<MessageResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MessageDialog(recipient: user),
    );

    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Sent to ${user.name} via ${result.channelSummary}.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // IndexedStack keeps every tab alive, so switching tabs is instant.
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ProfilePage(user: _user, isLoading: _isLoading),
          UserStateView(
            isLoading: _isLoading,
            user: _user,
            builder: (context, user) => AboutPage(user: user),
          ),
          UserStateView(
            isLoading: _isLoading,
            user: _user,
            builder: (context, user) => MissionVisionPage(user: user),
          ),
          UserStateView(
            isLoading: _isLoading,
            user: _user,
            builder: (context, user) => ContactPage(
              user: user,
              onMessage: _openMessageDialog,
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 ? _buildActionButtons() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Mission',
          ),
          NavigationDestination(
            icon: Icon(Icons.contact_mail_outlined),
            selectedIcon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
        ],
      ),
    );
  }

  /// "Message" sits right next to "Refresh User".
  Widget _buildActionButtons() {
    final canMessage = !_isLoading && _user != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: 'message_fab',
          onPressed: canMessage ? _openMessageDialog : null,
          icon: const Icon(Icons.mail_outline),
          label: const Text('Message'),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.extended(
          heroTag: 'refresh_fab',
          onPressed: _isLoading ? null : _fetchUser,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh User'),
        ),
      ],
    );
  }
}
