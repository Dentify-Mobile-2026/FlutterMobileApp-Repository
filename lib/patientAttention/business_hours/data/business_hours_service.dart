import 'dart:convert';

import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:dentify_flutter/patientAttention/business_hours/domain/business_day.dart';
import 'package:http/http.dart' as http;

/// Lee y guarda el horario de atención (GET y PUT /api/v1/business-hours).
class BusinessHoursService {
  final String baseUrl;
  final http.Client? _client;

  BusinessHoursService(this.baseUrl, {http.Client? client}) : _client = client;

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<BusinessHours> getBusinessHours() async {
    final get = _client?.get ?? http.get;
    final response = await get(
      ApiConstants.endpoint(baseUrl, 'v1/business-hours'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw BusinessHoursException(
          _errorOf(response, 'No se pudo cargar el horario de atención'));
    }
    return BusinessHours.fromJson(
        json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
  }

  Future<BusinessHours> saveBusinessHours(List<BusinessDay> days) async {
    final put = _client?.put ?? http.put;
    final response = await put(
      ApiConstants.endpoint(baseUrl, 'v1/business-hours'),
      headers: await _headers(),
      body: json.encode({'days': days.map((d) => d.toJson()).toList()}),
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw BusinessHoursException(
          _errorOf(response, 'No se pudo guardar el horario de atención'));
    }
    return BusinessHours.fromJson(
        json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
  }

  static String _errorOf(http.Response response, String fallback) {
    try {
      final body = json.decode(utf8.decode(response.bodyBytes));
      if (body is Map && body['error'] is String) {
        return body['error'] as String;
      }
    } catch (_) {}
    return fallback;
  }
}

class BusinessHoursException implements Exception {
  final String message;
  const BusinessHoursException(this.message);

  @override
  String toString() => message;
}
