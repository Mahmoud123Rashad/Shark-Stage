import 'package:flutter/material.dart';
import 'package:finial_project/screens/offers/project_offers_service.dart';

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
        backgroundColor:Theme.of(context).colorScheme.primary,
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
                                Expanded(
                                  child: Text(
                                    offer["offeredBy"]?["firstName"] != null && offer["offeredBy"]?["lastName"] != null
                                        ? "${offer["offeredBy"]["firstName"]} ${offer["offeredBy"]["lastName"]}"
                                        : offer["offeredBy"]?["name"]?.toString() ?? "Unknown User",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                            if (offer["status"] == "pending") ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _rejectOffer(offer["_id"]?.toString() ?? ""),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('Reject'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _acceptOffer(offer["_id"]?.toString() ?? ""),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('Accept'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _acceptOffer(String offerId) async {
    if (offerId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Offer'),
        content: const Text('Are you sure you want to accept this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final success = await ProjectOffersService.acceptOffer(offerId);
    
    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer accepted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOffers(); // Reload offers
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to accept offer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectOffer(String offerId) async {
    if (offerId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Offer'),
        content: const Text('Are you sure you want to reject this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final success = await ProjectOffersService.rejectOffer(offerId);
    
    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer rejected successfully'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadOffers(); // Reload offers
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject offer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
