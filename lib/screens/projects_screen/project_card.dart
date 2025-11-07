import 'package:flutter/material.dart';
import '../project_details/project_details_screen.dart';
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
    final imageUrl = (project["images"] != null && project["images"].isNotEmpty)
        ? project["images"][0]
        : "https://images.unsplash.com/photo-1506765515384-028b60a970df?auto=format&fit=crop&w=800&q=60";

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
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
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
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProjectDetailsScreen(projectId: project["_id"]),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                label: const Text("View Full Project"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
