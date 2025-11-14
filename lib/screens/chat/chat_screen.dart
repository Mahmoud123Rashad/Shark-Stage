import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/chat_service.dart';
import '../../services/auth_storage.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherParticipantName;
  final String? otherParticipantImage;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherParticipantName,
    this.otherParticipantImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final userSummary = await AuthStorage.getUserSummary();
    _currentUserId = userSummary['id'];

    // Initialize socket and join conversation
    await ChatService.initializeSocket();
    ChatService.joinConversation(widget.conversationId);

    // Load messages
    await _loadMessages();

    // Listen for new messages via Socket.IO
    final messageStream = ChatService.getMessageStream(widget.conversationId);
    if (messageStream != null) {
      _messageSubscription = messageStream.listen((data) {
        if (data['message'] != null) {
          setState(() {
            _messages.add(data['message']);
          });
          _scrollToBottom();
        }
      });
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    final messages = await ChatService.getMessages(widget.conversationId);
    
    setState(() {
      _messages = messages;
      _isLoading = false;
    });

    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    // Get other participant ID from conversation
    final conversations = await ChatService.getConversations();
    Map<String, dynamic>? conversation;
    try {
      conversation = conversations.firstWhere(
        (c) => c['_id']?.toString() == widget.conversationId,
      ) as Map<String, dynamic>?;
    } catch (e) {
      conversation = null;
    }
    
    if (conversation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation not found')),
      );
      setState(() {
        _isSending = false;
      });
      return;
    }
    
    final otherParticipant = ChatService.getOtherParticipant(
      conversation,
      _currentUserId ?? '',
    );
    
    if (otherParticipant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to find recipient')),
      );
      return;
    }

    final receiverId = otherParticipant['_id']?.toString() ?? 
                      otherParticipant['id']?.toString();
    
    if (receiverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid recipient')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    // Optimistically add message to UI
    final tempMessage = {
      '_id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'sender': {'_id': _currentUserId},
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
    };
    setState(() {
      _messages.add(tempMessage);
    });
    _messageController.clear();
    _scrollToBottom();

    // Send message
    final result = await ChatService.sendMessage(receiverId, content);

    setState(() {
      _isSending = false;
    });

    if (result == null) {
      // Remove temp message on error
      setState(() {
        _messages.removeWhere((m) {
          final id = m['_id']?.toString() ?? '';
          return id.startsWith('temp_');
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    } else {
      // Replace temp message with real one
      if (result['newMessage'] != null) {
        setState(() {
          final tempIndex = _messages.indexWhere((m) {
            final id = m['_id']?.toString() ?? '';
            return id.startsWith('temp_');
          });
          if (tempIndex != -1) {
            _messages[tempIndex] = result['newMessage'];
          }
        });
      }
    }
  }

  bool _isCurrentUserMessage(Map<String, dynamic> message) {
    final senderId = message['sender']?['_id']?.toString() ?? 
                    message['sender']?['id']?.toString() ??
                    message['senderId']?.toString();
    return senderId == _currentUserId;
  }

  String _formatMessageTime(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';
    return DateFormat('HH:mm').format(date);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherParticipantImage != null &&
                      widget.otherParticipantImage!.isNotEmpty
                  ? NetworkImage(widget.otherParticipantImage!)
                  : null,
              child: widget.otherParticipantImage == null ||
                      widget.otherParticipantImage!.isEmpty
                  ? Text(
                      widget.otherParticipantName.isNotEmpty
                          ? widget.otherParticipantName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.otherParticipantName,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
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
                              'No messages yet',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isUser = _isCurrentUserMessage(message);
                          final content = message['content']?.toString() ?? '';
                          final time = _formatMessageTime(
                            message['createdAt']?.toString(),
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isUser) ...[
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          content,
                                          style: TextStyle(
                                            color: isUser
                                                ? Colors.white
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        if (time.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            time,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isUser
                                                  ? Colors.white70
                                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                if (isUser) ...[
                                  const SizedBox(width: 8),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.send,
                            color: theme.colorScheme.primary,
                          ),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

