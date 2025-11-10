import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../services/api_service.dart';
import '../services/auth_storage.dart';

enum DashboardRole { investor, owner, admin }

class DashboardStats {
  const DashboardStats({
    required this.totalProjects,
    required this.totalCapital,
    required this.averageProgress,
    required this.averageRoi,
    required this.investedCapital,
  });

  final int totalProjects;
  final double totalCapital;
  final double averageProgress;
  final double averageRoi;
  final double investedCapital;
}

class DashboardProject {
  const DashboardProject({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    required this.totalPrice,
    required this.currentFunding,
    required this.progress,
    required this.expectedRoi,
    required this.updatedAt,
    this.investedPercentage,
  });

  final String id;
  final String title;
  final String status;
  final String category;
  final double totalPrice;
  final double currentFunding;
  final double progress;
  final double expectedRoi;
  final DateTime updatedAt;
  final double? investedPercentage;

  double get investedAmount =>
      investedPercentage != null ? totalPrice * investedPercentage! / 100 : 0;
}

class TrendPoint {
  const TrendPoint({required this.label, required this.amount});

  final String label;
  final double amount;
}

class AllocationSlice {
  const AllocationSlice({required this.category, required this.count});

  final String category;
  final int count;
}

class DashboardData {
  const DashboardData({
    required this.role,
    required this.stats,
    required this.projects,
    required this.trend,
    required this.allocation,
    required this.notifications,
  });

  final DashboardRole role;
  final DashboardStats stats;
  final List<DashboardProject> projects;
  final List<TrendPoint> trend;
  final List<AllocationSlice> allocation;
  final List<String> notifications;
}

class DashboardController extends ChangeNotifier {
  DashboardController({this.userIdOverride});

  final String? userIdOverride;

  DashboardData? _data;
  bool _isLoading = false;
  String? _error;

  DashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final summary = await AuthStorage.getUserSummary();
      final role = _resolveRole(summary['role']);
      final userId = userIdOverride ?? summary['id'];

      final projects = await _fetchProjects(role, userId);
      final stats = _deriveStats(projects, role);
      final trend = _deriveTrend(projects, role);
      final allocation = _deriveAllocation(projects);
      final notifications = _deriveNotifications(projects, role);

      _data = DashboardData(
        role: role,
        stats: stats,
        projects: projects,
        trend: trend,
        allocation: allocation,
        notifications: notifications,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DashboardRole _resolveRole(String? rawRole) {
    switch (rawRole) {
      case 'admin':
        return DashboardRole.admin;
      case 'owner':
      case 'entrepreneur':
        return DashboardRole.owner;
      default:
        return DashboardRole.investor;
    }
  }

  Future<List<DashboardProject>> _fetchProjects(
    DashboardRole role,
    String? userId,
  ) async {
    Map<String, dynamic> response;

    if (role == DashboardRole.admin) {
      response = await ApiService.get('projects', auth: true);
      final list = response['allProjects'] as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => _normalizeProject(json, role))
          .toList();
    }

    if (userId == null || userId.isEmpty) {
      throw Exception('Unable to determine current user.');
    }

    if (role == DashboardRole.owner) {
      response = await ApiService.get('projects/user/$userId', auth: true);
      final list = response['userProjects'] as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => _normalizeProject(json, role))
          .toList();
    }

    // Investor
    response = await ApiService.get('investments/user/$userId', auth: true);
    final list = response['investments'] as List<dynamic>? ?? [];

    final projects = <DashboardProject>[];
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;

      Map<String, dynamic>? projectJson;
      if (item['project'] is Map<String, dynamic>) {
        projectJson = Map<String, dynamic>.from(item['project']);
      } else if (item['project'] != null) {
        final projectId = item['project'].toString();
        final single = await ApiService.get('projects/$projectId', auth: true);
        if (single['project'] is Map<String, dynamic>) {
          projectJson = Map<String, dynamic>.from(single['project']);
        }
      }

      if (projectJson != null) {
        projectJson['investedPercentage'] =
            (item['percentage'] as num?)?.toDouble();
        projects.add(_normalizeProject(projectJson, role));
      }
    }
    return projects;
  }

  DashboardProject _normalizeProject(
    Map<String, dynamic> json,
    DashboardRole role,
  ) {
    final categoryRaw = json['category'];
    String category = 'General';
    if (categoryRaw is Map && categoryRaw['en'] is String) {
      category = categoryRaw['en'];
    } else if (categoryRaw is String) {
      category = categoryRaw;
    }

    final updatedAt = DateTime.tryParse(
          json['updatedAt']?.toString() ?? '',
        ) ??
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();

    return DashboardProject(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Project',
      status: json['status']?.toString() ?? 'active',
      category: category,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      currentFunding: (json['currentFunding'] as num?)?.toDouble() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      expectedRoi: (json['expectedROI'] as num?)?.toDouble() ??
          (json['roi'] is String
              ? double.tryParse(json['roi'] as String) ?? 0
              : (json['roi'] as num?)?.toDouble() ?? 0),
      investedPercentage:
          role == DashboardRole.investor ? (json['investedPercentage'] as num?)?.toDouble() : null,
      updatedAt: updatedAt,
    );
  }

  DashboardStats _deriveStats(
    List<DashboardProject> projects,
    DashboardRole role,
  ) {
    if (projects.isEmpty) {
      return const DashboardStats(
        totalProjects: 0,
        totalCapital: 0,
        averageProgress: 0,
        averageRoi: 0,
        investedCapital: 0,
      );
    }

    final totals = projects.fold(
      <String, double>{
        'capital': 0,
        'progress': 0,
        'roi': 0,
        'invested': 0,
      },
      (map, project) {
        map['capital'] = (map['capital'] ?? 0) + project.totalPrice;
        map['progress'] = (map['progress'] ?? 0) + project.progress;
        map['roi'] = (map['roi'] ?? 0) + project.expectedRoi;
        if (role == DashboardRole.investor) {
          map['invested'] =
              (map['invested'] ?? 0) + project.investedAmount;
        }
        return map;
      },
    );

    final totalProjects = projects.length;
    return DashboardStats(
      totalProjects: totalProjects,
      totalCapital: totals['capital'] ?? 0,
      averageProgress: totalProjects > 0 ? (totals['progress'] ?? 0) / totalProjects : 0,
      averageRoi: totalProjects > 0 ? (totals['roi'] ?? 0) / totalProjects : 0,
      investedCapital: totals['invested'] ?? 0,
    );
  }

  List<TrendPoint> _deriveTrend(
    List<DashboardProject> projects,
    DashboardRole role,
  ) {
    if (projects.isEmpty) return const [];

    final sorted = [...projects]..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    final grouped = SplayTreeMap<String, double>();
    for (final project in sorted) {
      final key = '${project.updatedAt.year}-${project.updatedAt.month.toString().padLeft(2, '0')}';
      final amount = role == DashboardRole.investor
          ? project.investedAmount
          : project.currentFunding > 0
              ? project.currentFunding
              : project.totalPrice;
      grouped.update(key, (value) => value + amount, ifAbsent: () => amount);
    }

    return grouped.entries
        .map(
          (entry) => TrendPoint(
            label: entry.key,
            amount: entry.value,
          ),
        )
        .toList();
  }

  List<AllocationSlice> _deriveAllocation(List<DashboardProject> projects) {
    if (projects.isEmpty) return const [];
    final grouped = <String, int>{};
    for (final project in projects) {
      grouped.update(project.category, (value) => value + 1,
          ifAbsent: () => 1);
    }
    return grouped.entries
        .map((entry) => AllocationSlice(category: entry.key, count: entry.value))
        .toList();
  }

  List<String> _deriveNotifications(
    List<DashboardProject> projects,
    DashboardRole role,
  ) {
    if (projects.isEmpty) {
      return const [
        'No active projects yet. Add your first project to see insights.',
      ];
    }

    final notifications = <String>[];

    if (role == DashboardRole.investor) {
      final top =
          projects.where((p) => p.investedPercentage != null).take(3);
      for (final project in top) {
        notifications.add(
          '${project.title} progress updated to ${project.progress.toStringAsFixed(0)}%.',
        );
      }
    } else {
      final active = projects.take(3);
      for (final project in active) {
        notifications.add(
          '${project.title} is currently ${project.status} with ROI ${project.expectedRoi.toStringAsFixed(1)}%.',
        );
      }
    }

    return notifications;
  }
}

