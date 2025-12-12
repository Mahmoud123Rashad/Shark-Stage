import 'package:finial_project/screens/project_details/send_offer_screen.dart';
import 'package:finial_project/screens/chat/chat_screen.dart';
import 'package:finial_project/screens/edit_project/edit_project_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../utils/project_image.dart';
import '../services/auth_storage.dart';
import '../services/chat_service.dart';
import '../services/api_service.dart';
import 'app_network_image.dart';

class ProjectDetailsBody extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailsBody({super.key, required this.project});

  @override
  State<ProjectDetailsBody> createState() => _ProjectDetailsBodyState();
}

class _ProjectDetailsBodyState extends State<ProjectDetailsBody>
    with SingleTickerProviderStateMixin {
  bool _isInvestor = false;
  bool _isLoading = true;
  String? _currentUserId;
  bool _isOwner = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _checkUserRole();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _navigateToEditProject() {
    final projectId = widget.project['_id']?.toString() ?? 
                     widget.project['id']?.toString();
    if (projectId == null || projectId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProjectScreen(
          projectId: projectId,
          ownerId: _currentUserId,
        ),
      ),
    ).then((result) {
      // Refresh project details if edit was successful
      if (result == true && mounted) {
        // You might want to reload the project data here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${widget.project['title'] ?? 'this project'}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final projectId = widget.project['_id']?.toString() ?? 
                     widget.project['id']?.toString();
    if (projectId == null || projectId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project ID is missing'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final success = await ApiService.delete(
        'projects/delete/$projectId',
        auth: true,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to projects list
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete project'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  // Helper function to get category display text
  String _getCategoryText() {
    final category = widget.project['category'];
    if (category == null) return 'N/A';
    if (category is String) return category;
    if (category is Map) {
      return category['en']?.toString() ?? 
             category['ar']?.toString() ?? 
             'N/A';
    }
    return 'N/A';
  }

  // Helper function to format date
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        final parsed = DateTime.parse(date);
        return DateFormat('MMM yyyy', 'en_US').format(parsed);
      }
      if (date is DateTime) {
        return DateFormat('MMM yyyy', 'en_US').format(date);
      }
    } catch (e) {
      return date.toString();
    }
    return 'N/A';
  }

  // Helper function to open document URL
  Future<void> _openDocument(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open document'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening document: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          // Header content as SliverList
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Hero Section with Image, Title, and Basic Info
                _buildHeroSection(context, colorScheme),
                
                // Action Buttons
                _buildActionButtons(context, colorScheme),
                
                // Stats Cards
                _buildStatsCards(context, colorScheme),
                
                // Owner Info Card
                _buildOwnerCard(context, colorScheme),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
          // TabBar as SliverPersistentHeader
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: colorScheme.primary,
                tabs: const [
                  Tab(text: 'Overview', icon: Icon(Icons.description)),
                  Tab(text: 'Timeline', icon: Icon(Icons.timeline)),
                  Tab(text: 'Investors', icon: Icon(Icons.people)),
                  Tab(text: 'Documents', icon: Icon(Icons.folder)),
                  Tab(text: 'Risks & Returns', icon: Icon(Icons.analytics)),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, colorScheme),
          _buildTimelineTab(context, colorScheme),
          _buildInvestorsTab(context, colorScheme),
          _buildDocumentsTab(context, colorScheme),
          _buildRisksReturnsTab(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
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
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                ),
                errorWidget: Container(
                  height: 250,
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            // Edit and Delete buttons for owner
            if (!_isLoading && _isOwner)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: _navigateToEditProject,
                        tooltip: 'Edit Project',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _deleteProject,
                        tooltip: 'Delete Project',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getCategoryText(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                widget.project["title"] ?? "Untitled Project",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Short Description
              if (widget.project["shortDesc"] != null)
                Text(
                  widget.project["shortDesc"],
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Invest Now button - only for investors who are NOT the owner
          if (!_isLoading && _isInvestor && !_isOwner)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToSendOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
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
          // Spacing between buttons
          if (!_isLoading && _isInvestor && !_isOwner)
            const SizedBox(height: 12),
          // Start Chat button - only for users who are NOT the owner
          if (!_isLoading && !_isOwner)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _startChatWithOwner,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
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
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              'ROI',
              '${widget.project["expectedROI"] ?? 0}%',
              Icons.trending_up,
              colorScheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Status',
              (widget.project["status"] ?? "Unknown").toString().toUpperCase(),
              Icons.info_outline,
              colorScheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Available',
              '${widget.project["availablePercentage"] ?? 0}%',
              Icons.pie_chart,
              colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
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
        ),
      ),
    );
  }

  Widget _buildOwnerCard(BuildContext context, ColorScheme colorScheme) {
    final owner = widget.project['owner'];
    if (owner == null) return const SizedBox.shrink();

    final ownerFirstName = owner['firstName']?.toString() ?? '';
    final ownerLastName = owner['lastName']?.toString() ?? '';
    final ownerName = '$ownerFirstName $ownerLastName'.trim();
    final ownerImage = owner['profilePicUrl']?.toString();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: ownerImage != null && ownerImage.isNotEmpty
                    ? NetworkImage(ownerImage)
                    : null,
                child: ownerImage == null || ownerImage.isEmpty
                    ? Text(
                        ownerName.isNotEmpty
                            ? ownerName[0].toUpperCase()
                            : 'O',
                        style: const TextStyle(fontSize: 24),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Owner',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ownerName.isNotEmpty ? ownerName : 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Indicator
          if (widget.project["progress"] != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Investment Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.project["progress"]}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (widget.project["progress"] ?? 0) / 100,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
                const SizedBox(height: 24),
              ],
            ),

          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.project["description"] ?? "No description available",
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // Key Benefits
          if (widget.project["keyBenefits"] != null &&
              (widget.project["keyBenefits"] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Key Benefits',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...(widget.project["keyBenefits"] as List)
                    .map<Widget>((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                const SizedBox(height: 24),
              ],
            ),

          // Potential Risks
          if (widget.project["potentialRisks"] != null &&
              (widget.project["potentialRisks"] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Potential Risks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...(widget.project["potentialRisks"] as List)
                    .map<Widget>((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.warning_amber,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),

          // Management Team
          if (widget.project["managementTeam"] != null &&
              (widget.project["managementTeam"] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Management Team',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...(widget.project["managementTeam"] as List)
                    .map<Widget>((member) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: member['image'] != null
                                  ? NetworkImage(member['image'])
                                  : null,
                              child: member['image'] == null
                                  ? Text(
                                      (member['name'] ?? 'M')[0].toUpperCase(),
                                    )
                                  : null,
                            ),
                            title: Text(member['name'] ?? 'Unknown'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member['role'] ?? ''),
                                if (member['bio'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      member['bio'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTimelineTab(BuildContext context, ColorScheme colorScheme) {
    final timeline = widget.project["timeline"];
    if (timeline == null || timeline is! List || timeline.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No timeline available',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    final timelineList = timeline;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(timelineList.length, (index) {
        final phase = timelineList[index];
        final status = phase['status']?.toString() ?? 'upcoming';
        final isCompleted = status == 'completed';
        final isInProgress = status == 'in-progress';

        Color statusColor;
        IconData statusIcon;
        if (isCompleted) {
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
        } else if (isInProgress) {
          statusColor = Colors.orange;
          statusIcon = Icons.radio_button_checked;
        } else {
          statusColor = Colors.grey;
          statusIcon = Icons.radio_button_unchecked;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: Colors.white, size: 24),
                ),
                if (index < timelineList.length - 1)
                  Container(
                    width: 2,
                    height: 60,
                    color: colorScheme.surfaceContainerHighest,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              phase['phase'] ?? 'Phase ${index + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.replaceAll('-', ' ').toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        phase['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (phase['date'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          phase['date'],
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
        }),
      ),
    );
  }

  Widget _buildInvestorsTab(BuildContext context, ColorScheme colorScheme) {
    final investors = widget.project["investors"];
    if (investors == null || investors is! List || investors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No investors yet',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    final investorsList = investors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(investorsList.length, (index) {
        final investor = investorsList[index];
        final user = investor['user'];
        final percentage = investor['percentage'] ?? 0;
        final investedAt = investor['investedAt'];

        final firstName = user?['firstName']?.toString() ?? '';
        final lastName = user?['lastName']?.toString() ?? '';
        final name = '$firstName $lastName'.trim();
        final image = user?['profilePicUrl']?.toString();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: image != null && image.isNotEmpty
                  ? NetworkImage(image)
                  : null,
              child: image == null || image.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'I',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            title: Text(name.isNotEmpty ? name : 'Unknown Investor'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${percentage}% invested'),
                if (investedAt != null)
                  Text(
                    _formatDate(investedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            trailing: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        );
        }),
      ),
    );
  }

  Widget _buildDocumentsTab(BuildContext context, ColorScheme colorScheme) {
    final documents = widget.project["documents"];
    if (documents == null || documents is! List || documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 64, color: colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No documents available',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    final documentsList = documents;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(documentsList.length, (index) {
        final doc = documentsList[index];
        final title = doc['title']?.toString() ?? 'Document ${index + 1}';
        final fileUrl = doc['fileUrl']?.toString() ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.description, color: colorScheme.primary, size: 32),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'PDF Document',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: fileUrl.isNotEmpty
                  ? () => _openDocument(fileUrl)
                  : null,
            ),
            onTap: fileUrl.isNotEmpty ? () => _openDocument(fileUrl) : null,
          ),
        );
        }),
      ),
    );
  }

  Widget _buildRisksReturnsTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risks Section
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Potential Risks',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.project["potentialRisks"] != null &&
              (widget.project["potentialRisks"] as List).isNotEmpty)
            ...(widget.project["potentialRisks"] as List)
                .map<Widget>((risk) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.orange.withOpacity(0.1),
                      child: ListTile(
                        leading: Icon(Icons.warning_amber, color: Colors.orange),
                        title: Text(
                          risk.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ))
                .toList()
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No risks identified',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 32),

          // Returns Section
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Expected Returns',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ROI Card
          Card(
            color: Colors.green.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROI Target',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.project["expectedROI"] ?? 0}%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Additional Returns Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Total Price',
                    '\$${widget.project["totalPrice"] ?? 0}',
                    Icons.attach_money,
                    colorScheme,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    'Available Percentage',
                    '${widget.project["availablePercentage"] ?? 0}%',
                    Icons.pie_chart,
                    colorScheme,
                  ),
                  if (widget.project["progress"] != null) ...[
                    const Divider(),
                    _buildInfoRow(
                      'Investment Progress',
                      '${widget.project["progress"]}%',
                      Icons.trending_up,
                      colorScheme,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Delegate class for SliverPersistentHeader to make TabBar sticky
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
