import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProjectDetailsBody extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectDetailsBody({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project["images"] != null && project["images"].isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                project["images"][0],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 20),

          Text(
            project["title"] ?? "Untitled Project",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          Text(
            project["description"] ?? "No description available",
            style: const TextStyle(fontSize: 18, height: 1.5),
          ),
          const SizedBox(height: 15),

          Text(
            "Category: ${project["category"] ?? "N/A"}",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),

          Text(
            "Total Price: \$${project["totalPrice"] ?? 0}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            "Expected ROI: ${project["expectedROI"] ?? 0}%",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),

          Text(
            "Status: ${project["status"] ?? "Unknown"}",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 25),

          if (project["keyBenefits"] != null && project["keyBenefits"].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Key Benefits:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...project["keyBenefits"]
                    .map<Widget>((b) => Text("• $b"))
                    .toList(),
              ],
            ),
          const SizedBox(height: 20),

          if (project["potentialRisks"] != null && project["potentialRisks"].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Potential Risks:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...project["potentialRisks"]
                    .map<Widget>((r) => Text("• $r"))
                    .toList(),
              ],
            ),
        ],
      ),
    );
  }
}
