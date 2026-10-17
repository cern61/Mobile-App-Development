import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import 'profile_avatar.dart';

/// Channels a message can be sent through.
enum MessageChannel {
  instant('Message', Icons.chat_bubble_outline),
  email('Email', Icons.mail_outline);

  const MessageChannel(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// What the dialog returns when the user presses "Send".
class MessageResult {
  const MessageResult({
    required this.channels,
    required this.subject,
    required this.body,
  });

  final Set<MessageChannel> channels;
  final String subject;
  final String body;

  /// Human readable channel list, e.g. "Message + Email".
  String get channelSummary => MessageChannel.values
      .where(channels.contains)
      .map((channel) => channel.label)
      .join(' + ');
}

/// UBYS-style "New Message" dialog.
///
/// This is a UI-only design: pressing "Send" simulates a short network call
/// and closes the dialog with a [MessageResult]; no real message is sent.
class MessageDialog extends StatefulWidget {
  const MessageDialog({super.key, required this.recipient});

  final UserProfile recipient;

  @override
  State<MessageDialog> createState() => _MessageDialogState();
}

class _MessageDialogState extends State<MessageDialog> {
  static const int _maxBodyLength = 500;
  static const int _maxAttachments = 3;

  static const List<({String label, String text})> _quickReplies = [
    (label: 'Hello', text: 'Hello, do you have a moment to talk?'),
    (label: 'Meeting', text: 'Can we schedule a meeting this week?'),
    (label: 'Document', text: 'Could you please send me the document?'),
    (label: 'Thanks', text: 'Thank you for your help!'),
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final List<String> _attachments = [];

  Set<MessageChannel> _channels = {MessageChannel.instant};
  bool _sendCopy = false;
  bool _isSending = false;
  int _attachmentCounter = 0;

  bool get _emailSelected => _channels.contains(MessageChannel.email);

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _useQuickReply(String text) {
    _bodyController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// UI demo only: a real app would open a file picker here.
  void _addAttachment() {
    if (_attachments.length >= _maxAttachments) return;
    setState(() {
      _attachmentCounter++;
      _attachments.add('document_$_attachmentCounter.pdf');
    });
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSending = true;
    });

    // Simulated network delay (UI-only assignment, nothing is really sent).
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    Navigator.of(context).pop(
      MessageResult(
        channels: _channels,
        subject: _subjectController.text.trim(),
        body: _bodyController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // The dialog cannot be dismissed while a message is being "sent".
      canPop: !_isSending,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: _buildForm(context),
                ),
              ),
              const Divider(height: 1),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      color: colors.primaryContainer,
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      child: Row(
        children: [
          Icon(Icons.forum_outlined, color: colors.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Message',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Send an instant message or an email',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            color: colors.onPrimaryContainer,
            icon: const Icon(Icons.close),
            onPressed: _isSending ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipient (read-only, shown as a chip like in UBYS).
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'To',
              helperText: widget.recipient.email,
              border: const OutlineInputBorder(),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: ProfileAvatar(user: widget.recipient, radius: 12),
                label: Text(widget.recipient.name),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Channel selector: message, email or both.
          Text('Send as', style: labelStyle),
          const SizedBox(height: 8),
          SegmentedButton<MessageChannel>(
            expandedInsets: EdgeInsets.zero,
            showSelectedIcon: false,
            multiSelectionEnabled: true,
            emptySelectionAllowed: false,
            segments: [
              for (final channel in MessageChannel.values)
                ButtonSegment<MessageChannel>(
                  value: channel,
                  icon: Icon(channel.icon),
                  label: Text(channel.label),
                ),
            ],
            selected: _channels,
            onSelectionChanged: _isSending
                ? null
                : (selection) {
                    setState(() {
                      _channels = selection;
                    });
                  },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _subjectController,
            enabled: !_isSending,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: _emailSelected ? 'Subject' : 'Subject (optional)',
              prefixIcon: const Icon(Icons.subject),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (_emailSelected && (value == null || value.trim().isEmpty)) {
                return 'Please enter a subject for the email.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Quick replies fill the message box with a ready-made sentence.
          Text('Quick replies', style: labelStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final reply in _quickReplies)
                ActionChip(
                  label: Text(reply.label),
                  onPressed:
                      _isSending ? null : () => _useQuickReply(reply.text),
                ),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _bodyController,
            enabled: !_isSending,
            minLines: 4,
            maxLines: 6,
            maxLength: _maxBodyLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Your message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please write a message.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Attachments (UI demo).
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _isSending || _attachments.length >= _maxAttachments
                    ? null
                    : _addAttachment,
                icon: const Icon(Icons.attach_file),
                label: const Text('Attach file'),
              ),
              const SizedBox(width: 12),
              Text(
                '${_attachments.length}/$_maxAttachments',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final name in _attachments)
                  InputChip(
                    avatar: const Icon(Icons.insert_drive_file_outlined),
                    label: Text(name),
                    onDeleted: _isSending
                        ? null
                        : () {
                            setState(() {
                              _attachments.remove(name);
                            });
                          },
                  ),
              ],
            ),
          ],
          const SizedBox(height: 4),

          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            title: const Text('Send me a copy'),
            value: _sendCopy,
            onChanged: _isSending
                ? null
                : (value) {
                    setState(() {
                      _sendCopy = value ?? false;
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSending ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _isSending ? null : _send,
            icon: _isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_isSending ? 'Sending...' : 'Send'),
          ),
        ],
      ),
    );
  }
}
