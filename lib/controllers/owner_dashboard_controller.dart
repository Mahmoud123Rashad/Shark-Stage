import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';

class Project {
  final String id;
  final String title;
  final String status;
  final double progress;

  Project({
    required this.id,
    required this.title,
    required this.status,
    this.progress = 0.0,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      status: json['status']?.toString() ?? 'Unknown',
      progress: 0.5,
    );
  }
}

class OwnerDashboardController {
  OwnerDashboardController({this.ownerId});

  final String? ownerId;

  Future<String?> _resolveOwnerId() async {
    if (ownerId != null && ownerId!.isNotEmpty) {
      return ownerId;
    }
    final summary = await AuthStorage.getUserSummary();
    return summary['id'];
  }

  Future<List<Project>> fetchOwnerProjects() async {
    final resolvedOwner = await _resolveOwnerId();
    if (resolvedOwner == null || resolvedOwner.isEmpty) {
      return [];
    }

    try {
      final response = await ApiService.get(
        'projects/user/$resolvedOwner',
        auth: true,
      );
      final status = response['status'] as int? ?? 500;
      if (status == 200 && response['userProjects'] is List<dynamic>) {
        final list = response['userProjects'] as List<dynamic>;
        return list
            .whereType<Map<String, dynamic>>()
            .map(Project.fromJson)
            .toList();
      }
      debugPrint(
        'Failed to load projects: ${response['message'] ?? 'status $status'}',
      );
      return [];
    } catch (e) {
      debugPrint('Error fetching owner projects: $e');
      return [];
    }
  }

  Future<Map<String, String>> fetchStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      "Projects": "12",
      "Earnings": "₤ 8,420",
      "NewOrders": "5",
      "Clients": "32",
    };
  }
}
