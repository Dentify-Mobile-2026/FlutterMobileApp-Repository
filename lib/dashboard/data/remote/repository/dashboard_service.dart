import 'dart:convert';

import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/dashboard/data/model/dashboard_response_dto.dart';
import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:http/http.dart' as http;

class DashboardApiService {
  final String baseUrl;

  DashboardApiService(this.baseUrl);

  Future<DashboardResponseDto> getDashboardData() async {
    final token =
        await TokenStorage.getAccessToken(); // <- Aquí se recupera el token
    print('Sending token: $token');

    if (token == null || token.isEmpty) {
      throw Exception("No access token found. Please login again.");
    }

    final response = await http.get(
      ApiConstants.endpoint(baseUrl, 'v1/dashboard'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return DashboardResponseDto.fromJson(json);
    } else {
      print('Dashboard error ${response.statusCode}: ${response.body}');
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
