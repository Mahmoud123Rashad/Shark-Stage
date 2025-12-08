// في ملف: lib/screens/notifications/notification_detail_screen.dart

import 'package:flutter/material.dart';

// استيراد الشاشات التي كانت تُستخدم في التنقل
import '../project_details/project_details_screen.dart';
import '../chat/chat_screen.dart';
import '../offers/sent_offers_screen.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({super.key, required this.notification});

  // 💡 دالة التنقل (Deep-Linking)
  // هذه الدالة مسؤولة عن نقلك من شاشة التفاصيل إلى الشاشة النهائية (الدردشة، المشروع، العرض)
  Future<void> _navigateByLink(BuildContext context, String link) async {
    final path = link.startsWith('/') ? link : '/$link';
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return;
    if (!context.mounted) return;

    if (segments[0] == 'projects' && segments.length >= 2) {
      final id = segments[1];
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProjectDetailsScreen(projectId: id)),
      );
      return;
    }

    if (segments[0] == 'chat' && segments.length >= 2) {
      // final conversationId = segments[1];
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ChatScreen(
            conversationId: '',
            otherParticipantName: 'Conversation',
          ),
        ),
      );
      return;
    }

    if (segments[0] == 'account' &&
        segments.length >= 2 &&
        segments[1] == 'offers') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SentOffersScreen()));
      return;
    }

    // Fallback
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Unknown link: $link')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = notification['link']?.toString() ?? '';

    // 💡 المحتوى الكامل: نبحث عن 'body' أو 'content' أولاً ثم نعتمد على 'message' كملخص
    final titleMessage =
        notification['message']?.toString() ?? 'No message summary.';
    final fullContent =
        notification['body']?.toString() ??
        notification['content']?.toString() ??
        titleMessage;

    final date = notification['createdAt']?.toString() ?? 'N/A';
    final type = notification['type']?.toString() ?? 'N/A';

    // 🟢 منطق التغيير الديناميكي: تحديد العنوان ونص الزر بناءً على نوع الإشعار
    String contentTitle = 'Notification Content';
    String buttonText = 'View Linked Content';
    IconData buttonIcon = Icons.open_in_new;

    if (type == 'message') {
      contentTitle = 'Full Message Content';
      buttonText = 'Go to Chat Conversation';
      buttonIcon = Icons.chat;
    } else if (type == 'offer_sent') {
      contentTitle = 'Offer Details';
      buttonText = 'View Offer Status';
      buttonIcon = Icons.local_offer;
    } else if (type?.startsWith('offer') == true) {
      contentTitle = 'Offer Status Update';
      buttonText = 'View Offer Details';
      buttonIcon = Icons.local_offer;
    } else if (type == 'comment') {
      contentTitle = 'Comment Details';
      buttonText = 'View Comment';
      buttonIcon = Icons.comment;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 نوع الإشعار والتاريخ
            Text(
              'Type: ${type.toUpperCase()}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text('Received Date', style: theme.textTheme.titleMedium),
            const SizedBox(height: 5),
            Text(date),
            const SizedBox(height: 20),

            // 💬 عرض المحتوى الكامل بشكل ديناميكي
            Text(
              contentTitle, // يتغير العنوان هنا بناءً على نوع الإشعار
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                fullContent,
                style: theme.textTheme.bodyLarge?.copyWith(
                  // خط مائل إذا كان المحتوى هو فقط الملخص (قد يشير إلى نقص البيانات الكاملة)
                  fontStyle: fullContent == titleMessage
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),

            // 🔗 زر الانتقال إلى الوجهة (Deep-Linking) - فقط للأنواع الأخرى غير الرسائل والعروض
            if (link.isNotEmpty &&
                type != 'message' &&
                !type.startsWith('offer')) ...[
              const SizedBox(height: 30),
              Text('Action', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _navigateByLink(context, link),
                icon: Icon(buttonIcon),
                label: Text(buttonText), // يتغير نص الزر هنا
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
