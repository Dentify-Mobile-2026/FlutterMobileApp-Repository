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
    print('Token: $token');
    final response = await http.get(
      ApiConstants.endpoint(baseUrl, 'v1/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return UserInfoResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener perfil: ${response.statusCode}');
    }
  }

  Future<void> updatePassword(UpdatePasswordRequest request) async {
    final token = await TokenStorage.getAccessToken();
    final response = await http.put(
      ApiConstants.endpoint(baseUrl, 'v1/profile/update-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar contraseña: ${response.statusCode}');
    }
  }

  Future<void> updateInformation(UpdateInformationRequest request) async {
    final token = await TokenStorage.getAccessToken();
    final response = await http.put(
      ApiConstants.endpoint(baseUrl, 'v1/profile/update-information'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar perfil: ${response.statusCode}');
    }
  }
}
