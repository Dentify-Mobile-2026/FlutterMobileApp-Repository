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

    final response = await http.get(
      ApiConstants.endpoint(baseUrl, 'v1/patients/$id/medical-histories'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("BODY: ${response.body}");
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map(
            (medicalHistory) => MedicalHistoryResponse.fromJson(medicalHistory),
          )
          .toList();
    } else {
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      throw Exception('Failed to load medical histories');
    }
  }

  Future<void> createMedicalHistory(
    AddMedicalHistoryRequest request,
    int id,
  ) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      ApiConstants.endpoint(baseUrl, 'v1/patients/$id/medical-histories'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create medical history');
    }
  }
}
