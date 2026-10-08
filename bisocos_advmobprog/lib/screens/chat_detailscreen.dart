import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';

/// Chat Detail Screen displays the conversation between two users
/// Features include message bubbles, status indicators, and smooth animations
class ChatDetailScreen extends StatefulWidget {
  final UserModel otherUser;

  const ChatDetailScreen({required this.otherUser, super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with WidgetsBindingObserver {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  String? _conversationId;
  bool _isLoading = true;
  bool _isMarkingMessagesSeen = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    _initializeConversation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Initialize conversation with other user
  Future<void> _initializeConversation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final chatService = context.read<ChatService>();
      await chatService.enableNetwork();
      final conversationId = await chatService.getOrCreateConversation(
        widget.otherUser.uid,
      );

      if (mounted) {
        setState(() {
          _conversationId = conversationId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _friendlyError(String error) {
    final normalizedError = error.toLowerCase();
    if (normalizedError.contains('unavailable') ||
        normalizedError.contains('offline')) {
      return 'Hindi maabot ang Firestore. I-check ang internet connection ng '
          'device o emulator, pagkatapos pindutin ang Retry.';
    }
    if (normalizedError.contains('permission-denied')) {
      return 'Walang permission ang account na ito sa conversation. '
          'Siguraduhing naka-sign in ang parehong users sa tamang Firebase project '
          'at tama ang Firestore rules.';
    }
    return 'Hindi mabuksan ang chat. Pindutin ang Retry para subukan ulit.';
  }

  Future<void> _markMessagesSeen() async {
    if (_conversationId == null || _isMarkingMessagesSeen) return;

    _isMarkingMessagesSeen = true;
    try {
      await context.read<ChatService>().markConversationAsSeen(
        _conversationId!,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update read status: $error')),
        );
      }
    } finally {
      _isMarkingMessagesSeen = false;
    }
  }

  /// Auto-scroll to latest message
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Send message
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _conversationId == null) return;

    try {
      final chatService = context.read<ChatService>();
      await chatService.sendMessage(
        _conversationId!,
        widget.otherUser.uid,
        message,
      );
      _messageController.clear();

      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _getDisplayName(widget.otherUser),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(_getDisplayName(widget.otherUser))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _friendlyError(_error!),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _initializeConversation,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Messages List
          Expanded(child: _buildMessagesList(context)),
          // Message Input
          _buildMessageInput(context),
        ],
      ),
    );
  }

  /// Build app bar with user information
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getDisplayName(widget.otherUser),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            widget.otherUser.email,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
    );
  }

  /// Build messages list
  Widget _buildMessagesList(BuildContext context) {
    if (_conversationId == null) {
      return const Center(child: Text('Unable to load conversation'));
    }

    final chatService = context.read<ChatService>();

    return StreamBuilder<List<Message>>(
      stream: chatService.getMessages(_conversationId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final messages = snapshot.data ?? [];
        if (messages.any(
          (message) =>
              message.receiverId == chatService.currentUserId &&
              message.status != MessageStatus.seen,
        )) {
          unawaited(_markMessagesSeen());
        }

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start the conversation!',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessageBubble(context, message);
          },
        );
      },
    );
  }

  /// Build individual message bubble with animations
  Widget _buildMessageBubble(BuildContext context, Message message) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSender =
        message.senderId == context.read<ChatService>().currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final dx = isSender ? 18 * (1 - value) : -18 * (1 - value);
            return Transform.translate(
              offset: Offset(dx, 10 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            decoration: BoxDecoration(
              color: isSender
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isSender ? 18 : 6),
                bottomRight: Radius.circular(isSender ? 6 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: isSender
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: isSender
                            ? colorScheme.onPrimary.withValues(alpha: 0.75)
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                    if (isSender) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(message.status, colorScheme),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build message status icon
  Widget _buildStatusIcon(MessageStatus status, ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.access_time_rounded;
        color = colorScheme.onPrimary.withValues(alpha: 0.8);
      case MessageStatus.sent:
        icon = Icons.check_rounded;
        color = colorScheme.onPrimary.withValues(alpha: 0.8);
      case MessageStatus.delivered:
        icon = Icons.done_all_rounded;
        color = colorScheme.onPrimary.withValues(alpha: 0.8);
      case MessageStatus.seen:
        icon = Icons.done_all_rounded;
        color = colorScheme.onPrimary;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        if (status == MessageStatus.sending) ...[
          const SizedBox(width: 4),
          Text(
            'sending',
            style: TextStyle(
              color: colorScheme.onPrimary.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// Build message input field
  Widget _buildMessageInput(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary,
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: colorScheme.onPrimary),
              onPressed: _sendMessage,
              tooltip: 'Send',
            ),
          ),
        ],
      ),
    );
  }

  /// Format timestamp to readable time
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  /// Get display name from user
  String _getDisplayName(UserModel user) {
    final firstName = user.firstName.trim();
    final lastName = user.lastName.trim();

    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }

    return user.username.isNotEmpty ? user.username : 'User';
  }
}

/// Fade-in animation widget for messages
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeInWidget({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    super.key,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fadeAnimation, child: widget.child);
  }
}
