import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/blog_service.dart';
import '../../services/auth_storage.dart';
import '../../widgets/comment_item.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/skeletons/skeleton_list.dart';

class BlogPostDetailsScreen extends StatefulWidget {
  final String postId;

  const BlogPostDetailsScreen({
    super.key,
    required this.postId,
  });

  @override
  State<BlogPostDetailsScreen> createState() => _BlogPostDetailsScreenState();
}

class _BlogPostDetailsScreenState extends State<BlogPostDetailsScreen> {
  Map<String, dynamic>? _post;
  List<dynamic> _comments = [];
  bool _isLoading = true;
  String? _error;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  bool _isDeletingPost = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadPostAndComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final token = await AuthStorage.getToken();
    if (token != null && token.isNotEmpty) {
      final user = await AuthStorage.getUser();
      setState(() {
        _isLoggedIn = true;
        _currentUser = user;
      });
    }
  }

  Future<void> _loadPostAndComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final post = await BlogService.getSinglePost(widget.postId);
      final comments = await BlogService.getPostComments(widget.postId);

      if (mounted) {
        setState(() {
          _post = post;
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load post: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmittingComment = true);

    try {
      final result = await BlogService.addComment(
        postId: widget.postId,
        content: _commentController.text.trim(),
      );

      if (result != null && mounted) {
        // Add author info to the comment before adding to list
        final commentWithAuthor = {
          ...result,
          'author': _currentUser != null
              ? {
                  '_id': _currentUser!['_id'] ?? _currentUser!['id'],
                  'firstName': _currentUser!['firstName'] ?? '',
                  'lastName': _currentUser!['lastName'] ?? '',
                  'profilePicUrl': _currentUser!['profilePicUrl'],
                }
              : null,
        };

        setState(() {
          _comments.insert(0, commentWithAuthor);
        });
        _commentController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add comment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final success = await BlogService.deleteComment(commentId);
    if (success && mounted) {
      await _loadPostAndComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete comment.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeletingPost = true);
      final success = await BlogService.deletePost(widget.postId);
      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        setState(() => _isDeletingPost = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete post.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _canDeletePost() {
    if (!_isLoggedIn || _post == null || _currentUser == null) return false;
    final authorId = _post!['author']?['_id']?.toString() ?? 
                     _post!['author']?['id']?.toString();
    final currentUserId = _currentUser!['_id']?.toString() ?? 
                          _currentUser!['id']?.toString();
    final accountType = _currentUser!['accountType']?.toString();
    return authorId == currentUserId || accountType == 'admin';
  }

  bool _canDeleteComment(Map<String, dynamic> comment) {
    if (!_isLoggedIn || _currentUser == null) return false;
    final authorId = comment['author']?['_id']?.toString() ?? 
                     comment['author']?['id']?.toString();
    final currentUserId = _currentUser!['_id']?.toString() ?? 
                          _currentUser!['id']?.toString();
    final accountType = _currentUser!['accountType']?.toString();
    return authorId == currentUserId || accountType == 'admin';
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inHours < 1) {
        return 'Just now';
      } else if (diff.inHours < 24) {
        return DateFormat('h:mm a').format(date);
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return DateFormat('EEEE').format(date);
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildAvatarPlaceholder(String name, ThemeData theme) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : '?';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        actions: [
          if (_canDeletePost())
            _isDeletingPost
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _deletePost,
                    tooltip: 'Delete Post',
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
                        onPressed: _loadPostAndComments,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _post == null
                  ? const Center(
                      child: Text('Post not found'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPostAndComments,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post Card
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Author Info
                                    Builder(
                                      builder: (context) {
                                        final author = _post!['author'] as Map<String, dynamic>?;
                                        final authorName = author != null
                                            ? '${author['firstName'] ?? ''} ${author['lastName'] ?? ''}'.trim()
                                            : 'Unknown';
                                        final authorImage = author?['profilePicUrl']?.toString();
                                        return Row(
                                          children: [
                                        if (authorImage != null && authorImage.isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(24),
                                            child: AppNetworkImage(
                                              imageUrl: authorImage,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorWidget: _buildAvatarPlaceholder(authorName, theme),
                                              placeholder: _buildAvatarPlaceholder(authorName, theme),
                                            ),
                                          )
                                        else
                                          _buildAvatarPlaceholder(authorName, theme),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                authorName,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 14,
                                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatTime(_post!['createdAt']?.toString()),
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    // Title
                                    Text(
                                      _post!['title']?.toString() ?? '',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Content
                                    Text(
                                      _post!['content']?.toString() ?? '',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Comments Section
                            Text(
                              'Comments (${_comments.length})',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Add Comment Form
                            if (_isLoggedIn)
                              Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextField(
                                        controller: _commentController,
                                        decoration: InputDecoration(
                                          hintText: 'Write a comment...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.all(12),
                                        ),
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: _isSubmittingComment ? null : _submitComment,
                                        icon: _isSubmittingComment
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : const Icon(Icons.send, size: 18),
                                        label: Text(_isSubmittingComment ? 'Posting...' : 'Comment'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Please login to comment',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            // Comments List
                            if (_comments.isEmpty)
                              EmptyState(
                                icon: Icons.comment_outlined,
                                title: 'No comments yet',
                                subtitle: 'Be the first to comment!',
                              )
                            else
                              ..._comments.map((comment) => CommentItem(
                                  comment: comment,
                                  canDelete: _canDeleteComment(comment),
                                  onDelete: () => _deleteComment(
                                    comment['_id']?.toString() ?? comment['id']?.toString() ?? '',
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

