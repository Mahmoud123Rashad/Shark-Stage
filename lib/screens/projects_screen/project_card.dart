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

    // Extract additional project info
    final roi = (project['expectedROI'] as num?)?.toDouble() ?? 0.0;
    final status = (project['status']?.toString() ?? 'active').toLowerCase();
    final category = project['category'];
    String? categoryName;
    if (category is Map) {
      categoryName = category['en']?.toString() ?? category['ar']?.toString();
    } else if (category is String) {
      categoryName = category;
    }

    return Card(
      color: isDark
          ? theme.colorScheme.surface.withOpacity(0.6)
          : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: isDark ? 4 : 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.outline.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppNetworkImage(
                    imageUrl: imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
                // Status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: status == 'active' ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // ROI badge
                if (roi > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${roi.toStringAsFixed(1)}% ROI',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 12),
            // Category and Price Row
            Row(
              children: [
                if (categoryName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          categoryName,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.secondary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "\$${price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton.icon(
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
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text("View Details"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
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
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text("Chat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
      ),
    );
  }
}
