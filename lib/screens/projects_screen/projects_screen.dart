import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/home/hero_section.dart';
import '../../widgets/home/stats_section.dart';
import '../../widgets/home/categories_section.dart';
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

  // Calculate statistics from projects
  Map<String, dynamic> _calculateStats() {
    if (_projects.isEmpty) {
      return {
        'totalProjects': 0,
        'totalInvestment': 0.0,
        'averageROI': 0.0,
        'activeProjects': 0,
      };
    }

    double totalInvestment = 0;
    double totalROI = 0;
    int activeCount = 0;
    int roiCount = 0;

    for (var project in _projects) {
      final price = (project['totalPrice'] as num?)?.toDouble() ?? 0;
      totalInvestment += price;

      final status = (project['status']?.toString() ?? '').toLowerCase();
      if (status == 'active') {
        activeCount++;
      }

      final roi = (project['expectedROI'] as num?)?.toDouble();
      if (roi != null && roi > 0) {
        totalROI += roi;
        roiCount++;
      }
    }

    return {
      'totalProjects': _projects.length,
      'totalInvestment': totalInvestment,
      'averageROI': roiCount > 0 ? totalROI / roiCount : 0.0,
      'activeProjects': activeCount,
    };
  }

  // Extract categories from projects
  List<CategoryItem> _extractCategories() {
    final categoryMap = <String, Map<String, dynamic>>{};

    for (var project in _projects) {
      final cat = project['category'];
      String? categoryName;
      
      if (cat is Map) {
        categoryName = cat['en']?.toString() ?? cat['ar']?.toString();
      } else if (cat is String) {
        categoryName = cat;
      }

      if (categoryName != null && categoryName.isNotEmpty) {
        if (categoryMap.containsKey(categoryName)) {
          categoryMap[categoryName]!['count']++;
        } else {
          categoryMap[categoryName] = {
            'name': categoryName,
            'count': 1,
          };
        }
      }
    }

    // Map category names to icons and colors
    final categoryIcons = {
      'Technology': Icons.computer,
      'E-Commerce': Icons.shopping_cart,
      'Food': Icons.restaurant,
      'Health': Icons.health_and_safety,
      'Education': Icons.school,
      'Real Estate': Icons.business,
      'Industrial': Icons.factory,
      'Other': Icons.category,
    };

    final categoryColors = {
      'Technology': Colors.blue,
      'E-Commerce': Colors.purple,
      'Food': Colors.orange,
      'Health': Colors.green,
      'Education': Colors.indigo,
      'Real Estate': Colors.brown,
      'Industrial': Colors.grey,
      'Other': Colors.teal,
    };

    return categoryMap.entries.map((entry) {
      final name = entry.value['name'] as String;
      final count = entry.value['count'] as int;
      return CategoryItem(
        id: name.toLowerCase().replaceAll(' ', '-'),
        name: name,
        icon: categoryIcons[name] ?? Icons.category,
        color: categoryColors[name] ?? Colors.grey,
        projectCount: count,
      );
    }).toList()
      ..sort((a, b) => b.projectCount.compareTo(a.projectCount));
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shark Stage"),
        centerTitle: true,
        elevation: 0,
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
      body: _isLoading
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
              : _buildHomeContent(),
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

  Widget _buildHomeContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stats = _calculateStats();
    final categories = _extractCategories();

    return Container(
      decoration: BoxDecoration(
        color: !isDark ? Colors.grey[50] : null,
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
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Section
          const SliverToBoxAdapter(
            child: HeroSection(),
          ),
          // Stats Section
          SliverToBoxAdapter(
            child: StatsSection(
              totalProjects: stats['totalProjects'] as int,
              totalInvestment: stats['totalInvestment'] as double,
              averageROI: stats['averageROI'] as double,
              activeProjects: stats['activeProjects'] as int,
            ),
          ),
          // Categories Section
          SliverToBoxAdapter(
            child: CategoriesSection(
              categories: categories,
              onCategoryTap: (categoryId) {
                // Find category name from ID
                final category = categories.firstWhere(
                  (c) => c.id == categoryId,
                  orElse: () => categories.first,
                );
                setState(() {
                  _filters = _filters.copyWith(
                    categories: [category.name],
                  );
                });
                _applyFiltersSort(resetPagination: true);
              },
            ),
          ),
          // Projects Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Projects',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (_filtered.isNotEmpty)
                    Text(
                      '${_filtered.length} projects',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Projects List
          _buildProjectsList(),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    if (_filtered.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No projects match your filters.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final visible = _filtered.take(_visibleCount).toList();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < visible.length) {
              final project = visible[index];
              return ProjectCard(project: project);
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          },
          childCount: visible.length + (_visibleCount < _filtered.length ? 1 : 0),
        ),
      ),
    );
  }
}
