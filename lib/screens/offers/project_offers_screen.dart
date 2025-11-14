import 'package:flutter/material.dart';
import 'package:finial_project/screens/offers/project_offers_service.dart';
import 'package:finial_project/theme/app_colors.dart';

class ProjectOffersScreen extends StatefulWidget {
  final String projectId;

  const ProjectOffersScreen({super.key, required this.projectId});

  @override
  State<ProjectOffersScreen> createState() => _ProjectOffersScreenState();
}

class _ProjectOffersScreenState extends State<ProjectOffersScreen> {
  bool _isLoading = true;
  List<dynamic> _offers = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final data = await ProjectOffersService.fetchOffers(widget.projectId);
    setState(() {
      _offers = data;
      _isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "cancelled":
        return Colors.grey;
      default:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Offers"),
        backgroundColor: AppColors.button,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offers.isEmpty
              ? const Center(
                  child: Text(
                    "No offers yet",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _offers.length,
                  itemBuilder: (context, index) {
                    final offer = _offers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  offer["offeredBy"]["name"] ?? "Unknown User",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusColor(offer["status"])
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    offer["status"],
                                    style: TextStyle(
                                      color: _statusColor(offer["status"]),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Percentage: ${offer["percentage"]}%",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Amount: \$${offer["amount"]}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (offer["proposalLetter"] != null &&
                                offer["proposalLetter"].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  offer["proposalLetter"],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
