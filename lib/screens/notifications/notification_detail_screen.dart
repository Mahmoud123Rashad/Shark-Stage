// في ملف: lib/screens/notifications/notification_detail_screen.dart

import 'package:flutter/material.dart';

// استيراد الشاشات التي كانت تُستخدم في التنقل
import '../project_details/project_details_screen.dart';
import '../chat/chat_screen.dart';
// 🛑 تأكد من أن هذا الاستيراد صحيح ويشير إلى شاشتك الفعلية
import '../offers/project_offers_screen.dart'; 


class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({super.key, required this.notification});

  // 💡 دالة التنقل (Deep-Linking)
  Future<void> _navigateByLink(BuildContext context, String link) async {
    final path = link.startsWith('/') ? link : '/$link';
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return;
    if (!context.mounted) return;

    // 🟢 منطق التنقل لصفحة المشروع وعروضه (المُعدّل)
    // نتوقع رابط بالشكل: /projects/<projectId>/offers أو /projects/<projectId>/offers/<offerId>
    if (segments[0] == 'projects' && segments.length >= 2) {
        final projectId = segments[1];
        
        // 1. اذا كان الرابط هو /projects/<projectId>/offers (أو أطول)
        if (segments.length >= 3 && segments[2] == 'offers') {
            final String? offerId = segments.length >= 4 ? segments[3] : null;

            await Navigator.of(context).push(
                MaterialPageRoute(
                    // 🛑 الانتقال إلى ProjectOffersScreen مع تمرير الـ ID و Offer ID
                    builder: (_) => ProjectOffersScreen(
                        projectId: projectId, 
                        initialOfferId: offerId // هذا هو معرّف العرض
                    ),
                ),
            );
            return;
        }

        // 2. إذا كان الرابط هو /projects/<projectId> فقط
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProjectDetailsScreen(projectId: projectId)),
        );
        return;
    }

    if (segments[0] == 'chat' && segments.length >= 2) {
      final conversationId = segments[1];
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId, otherParticipantName: '',
            // ... (بقية المتطلبات الأخرى لشاشة الدردشة)
          ),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = notification['link'] as String? ?? '';
    final fullContent = notification['fullContent'] as String? ?? '';
    final titleMessage = notification['message'] as String? ?? 'No Content';
    final type = notification['type'] as String? ?? '';
    
    // متغيرات لتغيير نص الأزرار والأيقونات حسب النوع
    String buttonText = 'Go to Linked Content';
    IconData buttonIcon = Icons.open_in_new;

    if (type == 'chat') {
      buttonText = 'Go to Chat';
      buttonIcon = Icons.message_outlined;
    } else if (type.startsWith('offer')) {
      buttonText = 'View Offer Details';
      buttonIcon = Icons.local_offer_outlined;
    } else if (type == 'project_status_update') {
      buttonText = 'View Project';
      buttonIcon = Icons.folder_open_outlined;
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Content',
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
                  fontStyle: fullContent == titleMessage ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            
            // 🔗 زر الانتقال إلى الوجهة (Deep-Linking)
            if (link.isNotEmpty) ...[
              const SizedBox(height: 30),
              Text(
                'Action',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _navigateByLink(context, link),
                icon: Icon(buttonIcon),
                label: Text(buttonText), 
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}