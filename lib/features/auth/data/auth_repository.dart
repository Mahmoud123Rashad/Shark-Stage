import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/network_exceptions.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/storage/token_storage_provider.dart';
import '../domain/app_user.dart';

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (Ref ref) => AuthRepository(
        apiClient: ref.watch(apiClientProvider),
        tokenStorage: ref.watch(tokenStorageProvider),
      ),
    );

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  static const String _authBase = '/auth';

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> response = await _apiClient.post<dynamic>(
      '$_authBase/signin',
      data: <String, dynamic>{'email': email, 'password': password},
    );

    final Map<String, dynamic> body = _expectJson(response);
    final String? token = body['token'] as String?;
    if (token != null) {
      await _tokenStorage.write(token);
    }
    final Map<String, dynamic> userJson =
        (body['user'] as Map<Object?, Object?>?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    return AppUser.fromJson(userJson);
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String accountType,
    required String firstName,
    required String lastName,
  }) async {
    final Response<dynamic> response = await _apiClient.post<dynamic>(
      '$_authBase/signup',
      data: <String, dynamic>{
        'email': email,
        'password': password,
        'accountType': accountType,
        'firstName': firstName,
        'lastName': lastName,
      },
    );

    final Map<String, dynamic> body = _expectJson(response);
    final Map<String, dynamic> userJson =
        (body['user'] as Map<Object?, Object?>?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    final String? token = body['token'] as String?;
    if (token != null) {
      await _tokenStorage.write(token);
    }

    return AppUser.fromJson(userJson);
  }

  Future<AppUser?> currentUser() async {
    try {
      final Response<dynamic> response = await _apiClient.get<dynamic>(
        '$_authBase/me',
      );
      final Map<String, dynamic> body = _expectJson(response);
      final Map<String, dynamic>? userJson =
          (body['user'] as Map<Object?, Object?>?)?.cast<String, dynamic>();
      if (userJson == null) return null;
      return AppUser.fromJson(userJson);
    } on NetworkResponseException catch (error) {
      if (error.statusCode == 401) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<dynamic>('$_authBase/logout');
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<AppUser> updateProfile(Map<String, dynamic> data) async {
    final Response<dynamic> response = await _apiClient.patch<dynamic>(
      '$_authBase/profile',
      data: data,
    );
    final Map<String, dynamic> body = _expectJson(response);
    final Map<String, dynamic> userJson =
        (body['user'] as Map<Object?, Object?>?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    return AppUser.fromJson(userJson);
  }

  Future<AppUser> uploadProfilePicture(FormData formData) async {
    final Response<dynamic> response = await _apiClient.post<dynamic>(
      '$_authBase/upload-profile-picture',
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    final Map<String, dynamic> body = _expectJson(response);
    final Map<String, dynamic> userJson =
        (body['user'] as Map<Object?, Object?>?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    return AppUser.fromJson(userJson);
  }

  Future<AppUser> authenticateWithGoogle({
    required String code,
    required String intent,
    String? accountType,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'code': code,
      'intent': intent,
      if (accountType != null && accountType.isNotEmpty)
        'accountType': accountType,
    };

    final Response<dynamic> response = await _apiClient.post<dynamic>(
      '$_authBase/google',
      data: payload,
    );

    final Map<String, dynamic> body = _expectJson(response);
    final Map<String, dynamic> userJson =
        (body['user'] as Map<Object?, Object?>?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    final String? token = body['token'] as String?;
    if (token != null) {
      await _tokenStorage.write(token);
    }

    return AppUser.fromJson(userJson);
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
