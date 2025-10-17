import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;
  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Details"),
        backgroundColor: AppColors.button,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('projects')
            .doc(projectId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Project not found."));
          }

          final project = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (project['imageUrl'] != null && project['imageUrl'] != '')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      project['imageUrl'],
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 20),

                // Title
                Text(
                  project['title'],
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Details
                Text(
                  project['details'],
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),

                // Price
                Text(
                  "Price: \$${project['price']}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Sale Type
                Text(
                  "Sale Type: ${project['saleType']}" +
                      (project['saleType'] == 'Partial'
                          ? " (${project['percentage']}%)"
                          : ""),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 15),

                // PDF Document
                if (project['pdfUrl'] != null && project['pdfUrl'] != '')
                  ElevatedButton(
                    onPressed: () async {
                      final url = project['pdfUrl'];
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Cannot open PDF")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                    ),
                    child: const Text("View Project PDF"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
