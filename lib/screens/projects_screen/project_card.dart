import 'package:flutter/material.dart';
import '../project_details/project_details_screen.dart';
import '../../utils/project_image.dart';
import '../../services/chat_service.dart';
import '../../services/auth_storage.dart';
import '../chat/chat_screen.dart';
import '../../widgets/app_network_image.dart';
class ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = project["title"] ?? "Untitled Project";
    final description = project["shortDesc"] ?? "No description";
    final price = project["totalPrice"] ?? 0;
    final imageUrl = resolveProjectImage(project);

    return Card(
      color: theme.cardColor.withOpacity(isDark ? 0.3 : 0.9),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppNetworkImage(
                imageUrl: imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: Container(
                  height: 180,
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                ),
                errorWidget: Container(
                  height: 180,
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 1.4,
                color:
                    theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Investment: \$${price.toString()}",
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  final pid = (project["_id"] ?? project["id"] ?? '').toString();
                  if (pid.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Project id is missing')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailsScreen(projectId: pid),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text("View"),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final owner = project['owner'];
                  final ownerId = (owner is Map<String, dynamic>)
                      ? (owner['_id']?.toString() ?? owner['id']?.toString() ?? '')
                      : owner?.toString() ?? '';
                  if (ownerId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Owner info not available')),
                    );
                    return;
                  }
                  final userSummary = await AuthStorage.getUserSummary();
                  final currentUserId = userSummary['id']?.toString();
                  if (currentUserId != null && currentUserId == ownerId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You cannot chat with yourself')),
                    );
                    return;
                  }
                  // Try to find existing conversation with the owner
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );
                  String? conversationId;
                  try {
                    final conversations = await ChatService.getConversations();
                    for (final c in conversations) {
                      if (c is Map<String, dynamic>) {
                        final other = ChatService.getOtherParticipant(c, currentUserId ?? '');
                        final otherId = other?['_id']?.toString() ?? other?['id']?.toString();
                        if (otherId == ownerId) {
                          conversationId = c['_id']?.toString();
                          break;
                        }
                      }
                    }
                  } catch (_) {}
                  if (Navigator.canPop(context)) Navigator.pop(context);
                  final ownerName = (owner is Map<String, dynamic>)
                      ? ('${owner['firstName'] ?? ''} ${owner['lastName'] ?? ''}').trim()
                      : 'Project Owner';
                  final ownerImage = (owner is Map<String, dynamic>)
                      ? owner['profilePicUrl']?.toString()
                      : null;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        conversationId: conversationId ?? '',
                        receiverId: ownerId,
                        otherParticipantName: ownerName.isNotEmpty ? ownerName : 'Project Owner',
                        otherParticipantImage: ownerImage,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat),
                label: const Text("Start Chat"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),

          ],
        ),
      ),
    );
  }
}
