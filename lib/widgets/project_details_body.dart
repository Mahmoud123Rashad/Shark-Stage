import 'package:finial_project/screens/project_details/send_offer_screen.dart';
import 'package:finial_project/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import '../utils/project_image.dart';
import '../services/auth_storage.dart';
import '../services/chat_service.dart';
import 'app_network_image.dart';

class ProjectDetailsBody extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailsBody({super.key, required this.project});

  @override
  State<ProjectDetailsBody> createState() => _ProjectDetailsBodyState();
}

class _ProjectDetailsBodyState extends State<ProjectDetailsBody> {
  bool _isInvestor = false;
  bool _isLoading = true;
  String? _currentUserId;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final userSummary = await AuthStorage.getUserSummary();
    final role = userSummary['role'];
    final userId = userSummary['id'];
    
    // Check if current user is the project owner
    final ownerId = widget.project['owner']?['_id']?.toString() ?? 
                   widget.project['owner']?.toString();
    final isOwner = userId != null && ownerId != null && userId == ownerId;
    
    setState(() {
      _isInvestor = role == 'investor';
      _currentUserId = userId;
      _isOwner = isOwner;
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

  Future<void> _startChatWithOwner() async {
    try {
      // Get owner information
      final owner = widget.project['owner'];
      if (owner == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Owner information not available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final ownerId = owner['_id']?.toString() ?? owner.toString();
      if (ownerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid owner information'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if current user is the owner
      if (_currentUserId != null && _currentUserId == ownerId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You cannot chat with yourself'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get owner name and image
      final ownerFirstName = owner['firstName']?.toString() ?? '';
      final ownerLastName = owner['lastName']?.toString() ?? '';
      final ownerName = '$ownerFirstName $ownerLastName'.trim();
      final ownerImage = owner['profilePicUrl']?.toString();

      // Try find existing conversation with owner
      String? conversationId;
      try {
        final conversations = await ChatService.getConversations();
        for (final c in conversations) {
          if (c is Map<String, dynamic>) {
            final other = ChatService.getOtherParticipant(c, _currentUserId ?? '');
            final otherId = other?['_id']?.toString() ?? other?['id']?.toString();
            if (otherId == ownerId) {
              conversationId = c['_id']?.toString();
              break;
            }
          }
        }
      } catch (_) {}

      // Navigate to chat screen
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            conversationId: conversationId ?? '',
            receiverId: ownerId,
            otherParticipantName: ownerName.isNotEmpty ? ownerName : 'Project Owner',
            otherParticipantImage: ownerImage,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            child: AppNetworkImage(
              imageUrl: resolveProjectImage(widget.project),
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: Container(
                height: 250,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
              ),
              errorWidget: Container(
                height: 250,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                child: const Icon(Icons.broken_image),
              ),
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
          
          // Start Chat Button (visible to all users except the owner)
          if (!_isLoading && !_isOwner)
            Padding(
              padding: EdgeInsets.only(top: _isInvestor ? 12 : 0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _startChatWithOwner,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.chat),
                  label: const Text(
                    'Start Chat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
