import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/chat_service.dart';
import '../../services/auth_storage.dart';
import 'chat_screen.dart';
import '../../widgets/protected_screen.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    final userSummary = await AuthStorage.getUserSummary();
    _currentUserId = userSummary['id'];

    final conversations = await ChatService.getConversations();
    
    setState(() {
      _conversations = conversations;
      _isLoading = false;
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  String _getLastMessagePreview(Map<String, dynamic>? lastMessage) {
    if (lastMessage == null) return 'No messages yet';
    return lastMessage['content']?.toString() ?? 'No messages yet';
  }

  String _getParticipantName(Map<String, dynamic> conversation) {
    final otherParticipant = ChatService.getOtherParticipant(
      conversation,
      _currentUserId ?? '',
    );
    if (otherParticipant == null) return 'Unknown User';
    
    final firstName = otherParticipant['firstName']?.toString() ?? '';
    final lastName = otherParticipant['lastName']?.toString() ?? '';
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return otherParticipant['email']?.toString() ?? 'Unknown User';
  }

  String? _getParticipantImage(Map<String, dynamic> conversation) {
    final otherParticipant = ChatService.getOtherParticipant(
      conversation,
      _currentUserId ?? '',
    );
    return otherParticipant?['profilePicUrl']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProtectedScreen(builder: (context) => Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a conversation with someone',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      final conversationId = conversation['_id']?.toString() ?? '';
                      final lastMessage = conversation['lastMessage'] as Map<String, dynamic>?;
                      final updatedAt = conversation['updatedAt']?.toString() ?? 
                                       conversation['createdAt']?.toString();
                      final participantName = _getParticipantName(conversation);
                      final participantImage = _getParticipantImage(conversation);
                      final lastMessagePreview = _getLastMessagePreview(lastMessage);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: participantImage != null && participantImage.isNotEmpty
                              ? NetworkImage(participantImage)
                              : null,
                          child: participantImage == null || participantImage.isEmpty
                              ? Text(
                                  participantName.isNotEmpty
                                      ? participantName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        title: Text(
                          participantName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          lastMessagePreview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDate(updatedAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                conversationId: conversationId,
                                otherParticipantName: participantName,
                                otherParticipantImage: participantImage,
                              ),
                            ),
                          ).then((_) {
                            // Refresh conversations when returning
                            _loadConversations();
                          });
                        },
                      );
                    },
                  ),
                ),
    ));
  }
}

