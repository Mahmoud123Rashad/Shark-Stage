import 'package:flutter/material.dart';
import '../../services/blog_service.dart';
import '../../services/auth_storage.dart';
import '../../widgets/blog_post_card.dart';
import '../../widgets/blog/blog_hero_section.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/skeletons/skeleton_list.dart';
import 'blog_post_details_screen.dart';
import 'add_post_dialog.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String? _error;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadPosts();
  }

  Future<void> _checkAuth() async {
    final token = await AuthStorage.getToken();
    if (token != null && token.isNotEmpty) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await BlogService.getAllPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load posts: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddPostDialog() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddPostDialog(),
    );

    if (result != null && mounted) {
      // Refresh posts after adding
      await _loadPosts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToPostDetails(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogPostDetailsScreen(postId: postId),
      ),
    ).then((_) {
      // Refresh posts when returning from details
      _loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
        elevation: 0,
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              onPressed: _showAddPostDialog,
              tooltip: 'New Post',
            ),
        ],
      ),
      body: _isLoading
          ? const SkeletonList()
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadPosts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _posts.isEmpty
                  ? Column(
                      children: [
                        const BlogHeroSection(),
                        Expanded(
                          child: EmptyState(
                            icon: Icons.article_outlined,
                            title: 'No posts yet',
                            subtitle: _isLoggedIn
                                ? 'Be the first to share something!'
                                : 'Check back later for new posts',
                            actionLabel: _isLoggedIn ? 'Add Post' : null,
                            onAction: _isLoggedIn ? _showAddPostDialog : null,
                          ),
                        ),
                      ],
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      child: CustomScrollView(
                        slivers: [
                          // Hero Section
                          const SliverToBoxAdapter(
                            child: BlogHeroSection(),
                          ),
                          // Posts List
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final post = _posts[index];
                                  final postId = post['_id']?.toString() ?? post['id']?.toString();
                                  if (postId == null || postId.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return BlogPostCard(
                                    post: post,
                                    onTap: () => _navigateToPostDetails(postId),
                                  );
                                },
                                childCount: _posts.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: _showAddPostDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Post'),
              tooltip: 'Add a new post',
            )
          : null,
    );
  }
}

