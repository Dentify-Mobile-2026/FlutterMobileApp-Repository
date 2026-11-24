import 'dart:convert';

import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/dashboard/data/model/dashboard_response_dto.dart';
import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:http/http.dart' as http;

class DashboardApiService {
  final String baseUrl;

  DashboardApiService(this.baseUrl);

  Future<DashboardResponseDto> getDashboardData() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesión no encontrada. Inicia sesión nuevamente.');
    }

    final response = await http
        .get(
          ApiConstants.endpoint(baseUrl, 'v1/dashboard'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return DashboardResponseDto.fromJson(data);
    } else {
      throw Exception('Error al cargar el panel (${response.statusCode})');
    }
  }
}
