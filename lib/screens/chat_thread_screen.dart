import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_spacing.dart';
import '../features/chat/data/chat_repository.dart';
import '../features/chat/domain/conversation.dart';
import '../theme/app_colors.dart';
import '../widgets/status_chip.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.otherParticipant,
  });

  final Conversation conversation;
  final String currentUserId;
  final ChatParticipant otherParticipant;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String content = _messageController.text.trim();
    if (content.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            receiverId: widget.otherParticipant.id,
            content: content,
          );
      _messageController.clear();
      ref.invalidate(messagesProvider(widget.conversation.id));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (mounted) _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ChatMessage>> threadAsync = ref.watch(
      messagesProvider(widget.conversation.id),
    );

    final String displayName = _formatParticipant(widget.otherParticipant);

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        backgroundColor: AppColors.accent,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: StatusChip(
              label: 'Active',
              tone: StatusTone.success,
              icon: Icons.circle,
              onTap: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: threadAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (Object error, StackTrace stackTrace) => Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Unable to load conversation.\n${error.toString()}',
                  textAlign: TextAlign.center,
                ),
              ),
              data: (List<ChatMessage> messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        'No messages yet. Start the conversation with a quick intro.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ChatMessage message = messages[index];
                    final bool isOwn =
                        message.sender?.id == widget.currentUserId;
                    return _MessageBubble(
                      message: message,
                      isOwn: isOwn,
                      otherParticipant: widget.otherParticipant,
                    );
                  },
                );
              },
            ),
          ),
          _Composer(
            controller: _messageController,
            isSending: _sending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Write a message…',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              onPressed: isSending ? null : onSend,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.sm),
              ),
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.otherParticipant,
  });

  final ChatMessage message;
  final bool isOwn;
  final ChatParticipant otherParticipant;

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor =
        isOwn ? AppColors.accent : AppColors.surfaceMuted;
    final Color textColor = isOwn ? AppColors.heading : AppColors.heading;
    final Alignment alignment =
        isOwn ? Alignment.centerRight : Alignment.centerLeft;
    final BorderRadius radius = isOwn
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOwn ? 'You' : _formatParticipant(otherParticipant),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: textColor.withValues(alpha: 0.7),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatTimestamp(message.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: textColor.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatParticipant(ChatParticipant participant) {
  final String first = participant.firstName ?? '';
  final String last = participant.lastName ?? '';
  final String name =
      ('$first $last').trim().isEmpty ? participant.email ?? 'Unknown' : '$first $last'.trim();
  return name;
}

String _formatTimestamp(DateTime? timestamp) {
  if (timestamp == null) return '';
  return DateFormat('MMM d • h:mm a').format(timestamp);
}

