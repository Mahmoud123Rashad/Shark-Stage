import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/project.dart';

final Provider<ProjectsRepository> projectsRepositoryProvider =
    Provider<ProjectsRepository>(
      (Ref ref) => ProjectsRepository(apiClient: ref.watch(apiClientProvider)),
    );

final FutureProviderFamily<Project, String> projectDetailsProvider =
    FutureProvider.family<Project, String>(
      (Ref ref, String id) =>
          ref.watch(projectsRepositoryProvider).fetchById(id),
    );

class ProjectsRepository {
  ProjectsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const String _basePath = '/projects';

  Future<List<Project>> fetchAll() async {
    final Response<dynamic> response = await _apiClient.get<dynamic>(_basePath);
    final Map<String, dynamic> body = _expectJson(response);
    final List<dynamic> projectsJson =
        body['allProjects'] as List<dynamic>? ?? <dynamic>[];
    return projectsJson
        .map(
          (dynamic json) => Project.fromJson(
            (json as Map<Object?, Object?>).cast<String, dynamic>(),
          ),
        )
        .toList();
  }

  Future<Project> fetchById(String id) async {
    final Response<dynamic> response = await _apiClient.get<dynamic>(
      '$_basePath/$id',
    );
    final Map<String, dynamic> body = _expectJson(response);
    final Map<String, dynamic> projectJson =
        (body['project'] as Map<Object?, Object?>?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    return Project.fromJson(projectJson);
  }

  Future<List<Project>> fetchForUser(String userId) async {
    final Response<dynamic> response = await _apiClient.get<dynamic>(
      '$_basePath/user/$userId',
    );
    final Map<String, dynamic> body = _expectJson(response);
    final List<dynamic> projectsJson =
        body['projects'] as List<dynamic>? ?? <dynamic>[];
    return projectsJson
        .map(
          (dynamic json) => Project.fromJson(
            (json as Map<Object?, Object?>).cast<String, dynamic>(),
          ),
        )
        .toList();
  }

  Future<String> addProject({
    required String ownerId,
    required String title,
    required String description,
    required String shortDesc,
    required String categoryEn,
    double? totalPrice,
    double? expectedROI,
    double? availablePercentage,
    File? image,
    String status = 'active',
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'owner': ownerId,
      'title': title,
      'description': description,
      'shortDesc': shortDesc,
      'status': status,
      'totalPrice': totalPrice?.toString() ?? '0',
      'expectedROI': expectedROI?.toString() ?? '0',
      'availablePercentage': availablePercentage?.toString() ?? '0',
      'category': jsonEncode(<String, String>{'en': categoryEn}),
    };

    final FormData formData = FormData.fromMap(payload);
    if (image != null) {
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split(Platform.pathSeparator).last,
          ),
        ),
      );
    }

    final Response<dynamic> response = await _apiClient.post<dynamic>(
      '$_basePath/add',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );

    final Map<String, dynamic> body = _expectJson(response);
    final String? newProjectId = body['newProjectId'] as String?;
    if (newProjectId == null) {
      throw const NetworkParsingException('Project identifier missing');
    }
    return newProjectId;
  }

  Map<String, dynamic> _expectJson(Response<dynamic> response) {
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is String && data.isNotEmpty) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw const NetworkParsingException('Unexpected response payload');
  }
}
