import 'package:flutter/material.dart';
import '../../services/blog_service.dart';
import '../../services/auth_storage.dart';
import '../../widgets/blog_post_card.dart';
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
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddPostDialog,
              tooltip: 'New Post',
            ),
        ],
      ),
      body: _isLoading
          ? const SkeletonList()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      ),
                    ],
                  ),
                )
              : _posts.isEmpty
                  ? EmptyState(
                      icon: Icons.article_outlined,
                      title: 'No posts yet',
                      subtitle: _isLoggedIn
                          ? 'Be the first to share something!'
                          : 'Check back later for new posts',
                      actionLabel: _isLoggedIn ? 'Add Post' : null,
                      onAction: _isLoggedIn ? _showAddPostDialog : null,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          final postId = post['_id']?.toString() ?? post['id']?.toString();
                          if (postId == null || postId.isEmpty) return const SizedBox.shrink();
                          return BlogPostCard(
                            post: post,
                            onTap: () => _navigateToPostDetails(postId),
                          );
                        },
                      ),
                    ),
    );
  }
}

