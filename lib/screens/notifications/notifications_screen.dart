import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/notification_service.dart';
import '../../services/chat_service.dart';
// 💡 حافظنا على هذه الاستيرادات لاستخدامها في شاشة التفاصيل الجديدة
import '../project_details/project_details_screen.dart';
import '../chat/chat_screen.dart';
import '../offers/sent_offers_screen.dart';
// 🟢 استيراد شاشة تفاصيل الإشعار الجديدة
import '../notifications/notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Initialize socket connection
    await ChatService.initializeSocket();
    await NotificationService.initializeNotificationListener();

    // Load initial notifications
    await _loadNotifications();

    // Listen for real-time notifications
    _notificationSubscription = NotificationService.notificationStream.listen((
      notification,
    ) {
      if (mounted) {
        // Add new notification to the list
        setState(() {
          _notifications.insert(0, notification);
          // Sort again to maintain order
          _notifications.sort((a, b) {
            final aRead = a['isRead'] == true;
            final bRead = b['isRead'] == true;
            if (aRead != bRead) {
              return aRead ? 1 : -1;
            }
            final aDate =
                DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
                DateTime.now();
            final bDate =
                DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
                DateTime.now();
            return bDate.compareTo(aDate);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final notifications = await NotificationService.getNotifications();

    // Sort: unread first, then by date
    notifications.sort((a, b) {
      final aRead = a['isRead'] == true;
      final bRead = b['isRead'] == true;
      if (aRead != bRead) {
        return aRead ? 1 : -1;
      }
      final aDate =
          DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.now();
      final bDate =
          DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(String notificationId, int index) async {
    final success = await NotificationService.markAsRead(notificationId);
    if (success && mounted) {
      setState(() {
        _notifications[index]['isRead'] = true;
      });
    }
  }

  // 🟢 دالة التعامل مع النقر على الإشعار بعد التعديل
  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    final notificationId = notification['_id']?.toString() ?? '';

    // 1. تحديد الإشعار كمقروء في واجهة المستخدم وقاعدة البيانات (إذا لم يكن مقروءاً بالفعل)
    if (notification['isRead'] != true) {
      final index = _notifications.indexWhere(
        (n) => n['_id']?.toString() == notificationId,
      );
      if (index != -1) {
        // نستخدم await لتحديث حالة القائمة قبل الانتقال
        await _markAsRead(notificationId, index);
      }
    }

    // 2. الانتقال إلى شاشة تفاصيل الإشعار لعرض المحتوى الكامل
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(
          notification: notification, // تمرير كائن الإشعار بالكامل
        ),
      ),
    );
  }

  // دالة التنقل بناءً على الرابط
  Future<void> _navigateByLink(String link) async {
    final path = link.startsWith('/') ? link : '/$link';
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return;
    if (!context.mounted) return;

    if (segments[0] == 'projects' && segments.length >= 2) {
      final id = segments[1];
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProjectDetailsScreen(projectId: id)),
      );
    } else if (segments[0] == 'chat' && segments.length >= 2) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ChatScreen(
            conversationId: '',
            otherParticipantName: 'Conversation',
          ),
        ),
      );
    } else if (segments[0] == 'account' &&
        segments.length >= 2 &&
        segments[1] == 'offers') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SentOffersScreen()));
    } else {
      // Fallback
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unknown link: $link')));
    }
  }

  // 🔴 تم حذف دالة _navigateByLink() حيث سيتم نقل منطقها إلى NotificationDetailScreen.

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'offer_sent':
      case 'offer_accepted':
      case 'offer_rejected':
      case 'offer_cancelled':
        return Icons.local_offer;
      case 'message':
        return Icons.message;
      case 'comment':
        return Icons.comment;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'offer_accepted':
        return Colors.green;
      case 'offer_rejected':
      case 'offer_cancelled':
        return Colors.red;
      case 'message':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will see updates here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final isRead = notification['isRead'] == true;
                  final type = notification['type']?.toString();
                  final message = notification['message']?.toString() ?? '';
                  final date = notification['createdAt']?.toString();

                  return Dismissible(
                    key: Key(
                      notification['_id']?.toString() ?? index.toString(),
                    ),
                    direction: isRead
                        ? DismissDirection.none
                        : DismissDirection.endToStart,
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      if (!isRead) {
                        _markAsRead(
                          notification['_id']?.toString() ?? '',
                          index,
                        );
                      }
                    },
                    child: InkWell(
                      onTap: () => _handleNotificationTap(notification),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isRead
                              ? theme.cardColor
                              : theme.colorScheme.primary.withOpacity(0.05),
                          border: Border(
                            left: BorderSide(
                              color: _getNotificationColor(type),
                              width: 4,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getNotificationColor(
                                  type,
                                ).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getNotificationIcon(type),
                                color: _getNotificationColor(type),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(date),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
