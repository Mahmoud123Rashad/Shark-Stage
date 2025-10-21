import 'package:flutter/material.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> projects = List.generate(10, (index) {
      return {
        'title': 'Project ${index + 1}',
        'details':
            'This is a brief description of project ${index + 1}. It focuses on innovation, technology, and business growth opportunities.',
        'price': (index + 1) * 5000,
        'imageUrl':
            'https://images.unsplash.com/photo-1506765515384-028b60a970df?auto=format&fit=crop&w=800&q=60',
      };
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Available Projects",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.appBarTheme.foregroundColor ?? Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF6A5AE0), Color(0xFF8F8AE6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];

            return Card(
              color: theme.cardColor.withOpacity(isDark ? 0.3 : 0.9),
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 6,
              shadowColor: theme.shadowColor.withOpacity(0.3),
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
                        project['imageUrl'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      project['title'],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      project['details'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        height: 1.4,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Investment: \$${project['price']}",
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                   Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(
            projectId: 'project_${index + 1}',
          ),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text("View Full Project"),
        SizedBox(width: 8),
        Icon(Icons.arrow_forward_ios, size: 16),
      ],
    ),
  ),
)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
