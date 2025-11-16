import 'dart:async';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/chat_service.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final bool showZero;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showZero = false,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  int _unreadCount = 0;
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

    // Load initial count
    await _loadUnreadCount();

    // Listen for real-time notifications
    _notificationSubscription = NotificationService.notificationStream.listen((notification) {
      if (mounted) {
        // Increment count when new notification arrives
        setState(() {
          if (notification['isRead'] != true) {
            _unreadCount++;
          }
        });
      }
    });
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || (!widget.showZero && _unreadCount == 0)) {
      return widget.child;
    }

    return Badge(
      label: Text(
        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
        style: const TextStyle(fontSize: 10),
      ),
      child: widget.child,
    );
  }
}

