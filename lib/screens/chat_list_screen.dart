import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/application/auth_state.dart';
import '../features/chat/data/chat_repository.dart';
import '../features/chat/domain/conversation.dart';
import '../theme/app_colors.dart';
import 'chat_thread_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Conversation> _filtered = <Conversation>[];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_applyFilter)
      ..dispose();
    super.dispose();
  }

  void _applyFilter() {
    final AsyncValue<List<Conversation>> conversations = ref.read(
      conversationsProvider,
    );
    final List<Conversation> data =
        conversations.asData?.value ?? <Conversation>[];
    final String query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filtered = data);
      return;
    }
    setState(() {
      _filtered = data
          .where(
            (Conversation convo) => convo.participants.any(
              (ChatParticipant participant) =>
                  '${participant.firstName ?? ''} ${participant.lastName ?? ''}'
                      .toLowerCase()
                      .contains(query),
            ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Conversation>> conversations = ref.watch(
      conversationsProvider,
    );
    final AuthState authState = ref.watch(authControllerProvider);
    final String? currentUserId = authState.maybeWhen(
      authenticated: (user) => user.id,
      orElse: () => null,
    );

    conversations.whenData((List<Conversation> value) {
      _filtered = value;
      _applyFilter();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.accent,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.9),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: conversations.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                error: (Object error, StackTrace stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (List<Conversation> _) {
                  if (_filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No conversations yet. Start connecting with founders or investors!',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (BuildContext context, int _) =>
                        const Divider(height: 0, color: Colors.white24),
                    itemBuilder: (BuildContext context, int index) {
                      final Conversation convo = _filtered[index];
                      final ChatParticipant otherParty = convo.participants
                          .firstWhere(
                            (ChatParticipant participant) =>
                                participant.id != currentUserId,
                            orElse: () => convo.participants.isNotEmpty
                                ? convo.participants.first
                                : const ChatParticipant(id: 'unknown'),
                          );
                      final String? userId = currentUserId;
                      final String displayName =
                          '${otherParty.firstName ?? ''} ${otherParty.lastName ?? ''}'
                              .trim()
                              .isEmpty
                          ? otherParty.email ?? 'Unknown contact'
                          : '${otherParty.firstName ?? ''} ${otherParty.lastName ?? ''}'
                                .trim();
                      final String lastMessage =
                          convo.lastMessage?.content ?? 'No messages yet';
                      final String time = _formatTime(
                        convo.lastMessage?.createdAt ?? convo.updatedAt,
                      );

                      return ListTile(
                        enabled: userId != null,
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.heading,
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        trailing: Text(
                          time,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        onTap: userId == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<Widget>(
                                    builder: (_) => ChatThreadScreen(
                                      conversation: convo,
                                      currentUserId: userId,
                                      otherParticipant: otherParty,
                                    ),
                                  ),
                                );
                              },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    final Duration diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
