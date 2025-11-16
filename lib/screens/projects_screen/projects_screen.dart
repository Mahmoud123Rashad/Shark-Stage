import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/notification_badge.dart';
import '../chatbot/chatbot_screen.dart';
import '../chat/conversations_list_screen.dart';
import '../notifications/notifications_screen.dart';
import 'project_filters.dart';
import 'project_card.dart';

class ProjectsScreen extends StatefulWidget {
  final String? userId;
  final String? role;

  const ProjectsScreen({
    super.key,
    this.userId,
    this.role,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<dynamic> _projects = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String? _error;

  // Filters/sorting/pagination
  ProjectFilters _filters = const ProjectFilters();
  String _sort = 'Newest';
  final List<String> _sortOptions = const ['Newest', 'ROI (High)', 'Price (Low)', 'Price (High)'];
  final int _pageSize = 10;
  int _visibleCount = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchProjects();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService.get('projects');
      final status = response['status'] as int? ?? 500;
      if (status == 200 && response['allProjects'] is List<dynamic>) {
        _projects = List<dynamic>.from(response['allProjects']);
        _applyFiltersSort(resetPagination: true);
        _isLoading = false;
        if (mounted) setState(() {});
      } else {
        setState(() {
          _error = response['message']?.toString() ??
              'Failed to fetch projects (status $status)';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching projects: $e");
      setState(() {
        _error = 'Failed to fetch projects: $e';
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_visibleCount < _filtered.length) {
        setState(() {
          _visibleCount = (_visibleCount + _pageSize).clamp(0, _filtered.length);
        });
      }
    }
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProjectFiltersSheet(
        initial: _filters,
        onApply: (f) {
          setState(() {
            _filters = f;
          });
          _applyFiltersSort(resetPagination: true);
        },
      ),
    );
  }

  void _applyFiltersSort({bool resetPagination = false}) {
    List<dynamic> working = List<dynamic>.from(_projects);

    // Categories (multi-select, empty means All)
    if (_filters.categories.isNotEmpty) {
      working = working.where((p) {
        final cat = p['category'];
        if (cat is Map) {
          final en = cat['en']?.toString();
          return en != null && _filters.categories.contains(en);
        }
        if (cat is String) return _filters.categories.contains(cat);
        return false;
      }).toList();
    }

    // Status
    if (_filters.status != null && _filters.status!.isNotEmpty) {
      working = working.where((p) => (p['status']?.toString() ?? '').toLowerCase() == _filters.status).toList();
    }

    // ROI
    if (_filters.minRoi != null) {
      working = working.where((p) {
        final roi = (p['expectedROI'] as num?)?.toDouble() ?? 0;
        return roi >= _filters.minRoi!;
      }).toList();
    }
    if (_filters.maxRoi != null) {
      working = working.where((p) {
        final roi = (p['expectedROI'] as num?)?.toDouble() ?? 0;
        return roi <= _filters.maxRoi!;
      }).toList();
    }

    // Price
    if (_filters.minPrice != null) {
      working = working.where((p) {
        final price = (p['totalPrice'] as num?)?.toDouble() ?? 0;
        return price >= _filters.minPrice!;
      }).toList();
    }
    if (_filters.maxPrice != null) {
      working = working.where((p) {
        final price = (p['totalPrice'] as num?)?.toDouble() ?? 0;
        return price <= _filters.maxPrice!;
      }).toList();
    }

    // Sorting
    switch (_sort) {
      case 'ROI (High)':
        working.sort((a, b) => ((b['expectedROI'] as num?)?.toDouble() ?? 0).compareTo(((a['expectedROI'] as num?)?.toDouble() ?? 0)));
        break;
      case 'Price (Low)':
        working.sort((a, b) => ((a['totalPrice'] as num?)?.toDouble() ?? 0).compareTo(((b['totalPrice'] as num?)?.toDouble() ?? 0)));
        break;
      case 'Price (High)':
        working.sort((a, b) => ((b['totalPrice'] as num?)?.toDouble() ?? 0).compareTo(((a['totalPrice'] as num?)?.toDouble() ?? 0)));
        break;
      case 'Newest':
      default:
        working.sort((a, b) {
          final aDate = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
    }

    _filtered = working;
    if (resetPagination) {
      _visibleCount = _pageSize.clamp(0, _filtered.length);
    } else {
      _visibleCount = _visibleCount.clamp(0, _filtered.length);
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Projects"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.tune),
            onPressed: _openFilters,
          ),
          PopupMenuButton<String>(
            tooltip: 'Sort',
            initialValue: _sort,
            onSelected: (value) {
              setState(() {
                _sort = value;
              });
              _applyFiltersSort();
            },
            itemBuilder: (context) => _sortOptions
                .map((s) => PopupMenuItem<String>(value: s, child: Text(s)))
                .toList(),
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ConversationsListScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: NotificationBadge(
              child: const Icon(Icons.notifications),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              ).then((_) {
                setState(() {});
              });
            },
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          color: !isDark ? Colors.white : null,
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF121212),
                    Color(0xFF1E1E1E),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
        ),

        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchProjects,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildList(),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatBotScreen()),
          );
        },
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text("AI Bot"),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildList() {
    if (_filtered.isEmpty) {
      return const Center(child: Text('No projects match your filters.'));
    }
    final visible = _filtered.take(_visibleCount).toList();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: visible.length + (_visibleCount < _filtered.length ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < visible.length) {
          final project = visible[index];
          // Render the same card used inside ProjectList without nesting ListViews
          return ProjectCard(project: project);
        }
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
