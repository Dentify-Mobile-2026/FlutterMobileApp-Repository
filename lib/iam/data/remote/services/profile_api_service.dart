import 'dart:convert';

import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/iam/data/model/user_info_response.dart';
import 'package:dentify_flutter/iam/data/remote/dto/update_infomation_request.dart';
import 'package:dentify_flutter/iam/data/remote/dto/update_password_request.dart';
import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:http/http.dart' as http;

class ProfileApiService {
  final String baseUrl;

  ProfileApiService(this.baseUrl);

  Future<UserInfoResponse> getUserInfo() async {
    final token = await TokenStorage.getAccessToken();
    final response = await http
        .get(
          ApiConstants.endpoint(baseUrl, 'v1/profile'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return UserInfoResponse.fromJson(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception(_extractError(response, 'Error al obtener perfil'));
    }
  }

  Future<void> updatePassword(UpdatePasswordRequest request) async {
    final token = await TokenStorage.getAccessToken();
    final response = await http
        .put(
          ApiConstants.endpoint(baseUrl, 'v1/profile/update-password'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractError(response, 'Error al actualizar contraseña'));
    }
  }

  Future<void> updateInformation(UpdateInformationRequest request) async {
    final token = await TokenStorage.getAccessToken();
    final response = await http
        .put(
          ApiConstants.endpoint(baseUrl, 'v1/profile/update-information'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractError(response, 'Error al actualizar perfil'));
    }
  }

  String _extractError(http.Response response, String fallback) {
    try {
      final body = json.decode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic> && body['error'] != null) {
        return body['error'].toString();
      }
    } catch (_) {}
    return '$fallback (${response.statusCode})';
  }
}
