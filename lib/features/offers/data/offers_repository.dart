import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/network_exceptions.dart';
import '../domain/offer.dart';

final Provider<OffersRepository> offersRepositoryProvider =
    Provider<OffersRepository>(
  (Ref ref) => OffersRepository(apiClient: ref.watch(apiClientProvider)),
);

class OffersRepository {
  OffersRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Offer>> fetchSent() async {
    final Response<dynamic> response =
        await _apiClient.get<dynamic>('/offers/sent');
    final Map<String, dynamic> body = _expectJson(response);
    final List<dynamic> raw = body['offers'] as List<dynamic>? ?? <dynamic>[];
    return raw
        .map(
          (dynamic json) => Offer.fromJson(
            (json as Map<Object?, Object?>).cast<String, dynamic>(),
          ),
        )
        .toList();
  }

  Future<List<Offer>> fetchReceived() async {
    final Response<dynamic> response =
        await _apiClient.get<dynamic>('/offers/received');
    final Map<String, dynamic> body = _expectJson(response);
    final List<dynamic> raw = body['offers'] as List<dynamic>? ?? <dynamic>[];
    return raw
        .map(
          (dynamic json) => Offer.fromJson(
            (json as Map<Object?, Object?>).cast<String, dynamic>(),
          ),
        )
        .toList();
  }

  Future<void> acceptOffer(String id) async {
    await _apiClient.patch<dynamic>('/offers/accept/$id');
  }

  Future<void> rejectOffer(String id) async {
    await _apiClient.patch<dynamic>('/offers/reject/$id');
  }

  Future<void> cancelOffer(String id) async {
    await _apiClient.patch<dynamic>('/offers/cancel/$id');
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

