import 'package:finial_project/screens/project_details/send_offer_screen.dart';
import 'package:flutter/material.dart';
import '../utils/project_image.dart';
import '../services/auth_storage.dart';

class ProjectDetailsBody extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailsBody({super.key, required this.project});

  @override
  State<ProjectDetailsBody> createState() => _ProjectDetailsBodyState();
}

class _ProjectDetailsBodyState extends State<ProjectDetailsBody> {
  bool _isInvestor = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final userSummary = await AuthStorage.getUserSummary();
    final role = userSummary['role'];
    setState(() {
      _isInvestor = role == 'investor';
      _isLoading = false;
    });
  }

  void _navigateToSendOffer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendOfferScreen(project: widget.project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              resolveProjectImage(widget.project),
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            widget.project["title"] ?? "Untitled Project",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Text(
            widget.project["description"] ?? "No description available",
            style: const TextStyle(fontSize: 18, height: 1.5),
          ),
          const SizedBox(height: 15),

          Text(
            "Category: ${widget.project["category"] ?? "N/A"}",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),

          Text(
            "Total Price: \$${widget.project["totalPrice"] ?? 0}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Text(
            "Expected ROI: ${widget.project["expectedROI"] ?? 0}%",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),

          Text(
            "Status: ${widget.project["status"] ?? "Unknown"}",
            style: const TextStyle(fontSize: 18, color: Colors.greenAccent),
          ),
          const SizedBox(height: 10),

          Text(
            "Available Percentage: ${widget.project["availablePercentage"] ?? 0}%",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 25),

          // Send Offer Button (only for investors)
          if (!_isLoading && _isInvestor)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToSendOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Invest now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 25),

          if (widget.project["keyBenefits"] != null &&
              widget.project["keyBenefits"].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Key Benefits:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.project["keyBenefits"]
                    .map<Widget>((b) => Text("• $b"))
                    .toList(),
              ],
            ),
          const SizedBox(height: 20),

          if (widget.project["potentialRisks"] != null &&
              widget.project["potentialRisks"].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Potential Risks:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.project["potentialRisks"]
                    .map<Widget>((r) => Text("• $r"))
                    .toList(),
              ],
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
