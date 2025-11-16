import 'api_service.dart';

class BlogService {
  // جلب جميع المنشورات
  static Future<List<dynamic>> getAllPosts() async {
    try {
      final response = await ApiService.get('blog', auth: false);
      
      if (response['status'] == 200 && response['success'] == true) {
        return response['allPosts'] as List<dynamic>? ?? [];
      } else {
        print("❌ Failed to load posts: ${response['status']}");
        return [];
      }
    } catch (e) {
      print("🔥 Error fetching posts: $e");
      return [];
    }
  }

  // جلب منشور واحد
  static Future<Map<String, dynamic>?> getSinglePost(String postId) async {
    try {
      final response = await ApiService.get('blog/$postId', auth: false);
      
      if (response['status'] == 200 && response['success'] == true) {
        return response['post'] as Map<String, dynamic>?;
      } else {
        print("❌ Failed to load post: ${response['status']}");
        return null;
      }
    } catch (e) {
      print("🔥 Error fetching post: $e");
      return null;
    }
  }

  // جلب تعليقات المنشور
  static Future<List<dynamic>> getPostComments(String postId) async {
    try {
      final response = await ApiService.get('blog/post/$postId', auth: false);
      
      if (response['status'] == 200 && response['success'] == true) {
        return response['postComments'] as List<dynamic>? ?? [];
      } else {
        print("❌ Failed to load comments: ${response['status']}");
        return [];
      }
    } catch (e) {
      print("🔥 Error fetching comments: $e");
      return [];
    }
  }

  // إضافة منشور جديد
  static Future<Map<String, dynamic>?> addPost({
    required String title,
    required String content,
  }) async {
    try {
      final response = await ApiService.post(
        'blog/post/add',
        body: {
          'title': title,
          'content': content,
        },
        auth: true,
      );
      
      if (response['status'] == 201 && response['success'] == true) {
        return response['newPost'] as Map<String, dynamic>?;
      } else {
        print("❌ Failed to add post: ${response['status']}");
        return null;
      }
    } catch (e) {
      print("🔥 Error adding post: $e");
      return null;
    }
  }

  // إضافة تعليق
  static Future<Map<String, dynamic>?> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await ApiService.post(
        'blog/comment/add',
        body: {
          'post': postId,
          'content': content,
        },
        auth: true,
      );
      
      if (response['status'] == 201 && response['success'] == true) {
        // API returns 'comment' not 'newComment'
        return response['comment'] as Map<String, dynamic>?;
      } else {
        print("❌ Failed to add comment: ${response['status']}");
        return null;
      }
    } catch (e) {
      print("🔥 Error adding comment: $e");
      return null;
    }
  }

  // حذف منشور
  static Future<bool> deletePost(String postId) async {
    try {
      final response = await ApiService.post(
        'blog/post/delete/$postId',
        auth: true,
      );
      
      final statusCode = response['status'] as int? ?? 500;
      return statusCode == 200 && response['success'] == true;
    } catch (e) {
      print("🔥 Error deleting post: $e");
      return false;
    }
  }

  // حذف تعليق
  static Future<bool> deleteComment(String commentId) async {
    try {
      final response = await ApiService.post(
        'blog/comment/delete/$commentId',
        auth: true,
      );
      
      final statusCode = response['status'] as int? ?? 500;
      return statusCode == 200 && response['success'] == true;
    } catch (e) {
      print("🔥 Error deleting comment: $e");
      return false;
    }
  }
}

