import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;
  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final String baseUrl = "https://sharkserver-production.up.railway.app";
  Map<String, dynamic>? _project;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProjectDetails();
  }

  Future<void> fetchProjectDetails() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/projects/${widget.projectId}"));
      debugPrint(" GET /projects/${widget.projectId} => ${response.statusCode}");
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _project = data["project"] ?? data;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load project details");
      }
    } catch (e) {
      debugPrint("❌ Error fetching project details: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = _project;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Details"),
        backgroundColor: AppColors.button,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : project == null
              ? const Center(child: Text("Project not found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (project["images"] != null &&
                          project["images"].isNotEmpty)
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

                      if (project["keyBenefits"] != null &&
                          project["keyBenefits"].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Key Benefits:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...project["keyBenefits"]
                                .map<Widget>((b) => Text("• $b"))
                                .toList(),
                          ],
                        ),

                      const SizedBox(height: 20),

                      if (project["potentialRisks"] != null &&
                          project["potentialRisks"].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Potential Risks:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...project["potentialRisks"]
                                .map<Widget>((r) => Text("• $r"))
                                .toList(),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }
}
