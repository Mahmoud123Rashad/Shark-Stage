import 'package:flutter/material.dart';
import 'package:finial_project/screens/offers/project_offers_service.dart';
import 'package:finial_project/screens/project_details/project_details_screen.dart';
import 'package:finial_project/theme/app_colors.dart';

class SentOffersScreen extends StatefulWidget {
  const SentOffersScreen({super.key, String? initialOfferId});

  @override
  State<SentOffersScreen> createState() => _SentOffersScreenState();
}

class _SentOffersScreenState extends State<SentOffersScreen> {
  bool _isLoading = true;
  List<dynamic> _offers = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
    });
    final data = await ProjectOffersService.fetchSentOffers();
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

  String _getStatusLabel(String status) {
    switch (status) {
      case "accepted":
        return "Accepted";
      case "rejected":
        return "Rejected";
      case "cancelled":
        return "Cancelled";
      default:
        return "Pending";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sent Offers"),
        backgroundColor: AppColors.button,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offers.isEmpty
              ? const Center(
                  child: Text(
                    "No offers sent yet",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOffers,
                  child: ListView.builder(
                    itemCount: _offers.length,
                    itemBuilder: (context, index) {
                      final offer = _offers[index];
                      final project = offer["project"];
                      final projectId = project?["_id"]?.toString() ?? "";
                      final projectTitle = project?["title"]?.toString() ?? "Unknown Project";
                      
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          projectTitle,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (project?["category"] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              project["category"] is Map
                                                  ? (project["category"]["en"]?.toString() ?? 
                                                     project["category"]["ar"]?.toString() ?? "")
                                                  : project["category"].toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                      ],
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
                                      _getStatusLabel(offer["status"]),
                                      style: TextStyle(
                                        color: _statusColor(offer["status"]),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoRow(
                                      "Amount",
                                      "\$${offer["amount"]?.toStringAsFixed(2) ?? "0.00"}",
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoRow(
                                      "Percentage",
                                      "${offer["percentage"]?.toStringAsFixed(1) ?? "0"}%",
                                    ),
                                  ),
                                ],
                              ),
                              if (offer["proposalLetter"] != null &&
                                  offer["proposalLetter"].toString().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                const Text(
                                  "Proposal:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  offer["proposalLetter"],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (projectId.isNotEmpty)
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ProjectDetailsScreen(
                                              projectId: projectId,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.visibility, size: 18),
                                      label: const Text('View Project'),
                                    ),
                                  if (offer["status"] == "pending") ...[
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => _cancelOffer(offer["_id"]?.toString() ?? ""),
                                      icon: const Icon(Icons.cancel, size: 18),
                                      label: const Text('Cancel'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _cancelOffer(String offerId) async {
    if (offerId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Offer'),
        content: const Text('Are you sure you want to cancel this offer? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final success = await ProjectOffersService.cancelOffer(offerId);
    
    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer cancelled successfully'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadOffers(); // Reload offers
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel offer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

