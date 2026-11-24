import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/patientAttention/patients/data/model/medical_history_response.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_medical_history_request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicalHistoryService {
  final String baseUrl;

  MedicalHistoryService(this.baseUrl);

  Future<List<MedicalHistoryResponse>> getAllMedicalHistories(int id) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http
        .get(
          ApiConstants.endpoint(baseUrl, 'v1/patients/$id/medical-histories'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse =
          json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse
          .map(
            (medicalHistory) => MedicalHistoryResponse.fromJson(medicalHistory),
          )
          .toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error al cargar historial clínico (${response.statusCode})');
    }
  }

  Future<void> createMedicalHistory(
    AddMedicalHistoryRequest request,
    int id,
  ) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http
        .post(
          ApiConstants.endpoint(baseUrl, 'v1/patients/$id/medical-histories'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      throw Exception('Error al guardar evolución clínica');
    }
  }
}
