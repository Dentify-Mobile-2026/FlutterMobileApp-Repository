import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/patientAttention/patients/data/model/patient_response.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/update_patient_request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientService {
  final String baseUrl;

  PatientService(this.baseUrl);

  Future<List<PatientResponse>> getAllPatients() async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      ApiConstants.endpoint(baseUrl, 'v1/patients'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("BODY: ${response.body}");
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((patient) => PatientResponse.fromJson(patient))
          .toList();
    } else {
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      throw Exception('Failed to load patients');
    }
  }

  Future<void> createPatient(AddPatientRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      ApiConstants.endpoint(baseUrl, 'v1/patients'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create patient');
    }
  }

  Future<void> deletePatient(int id) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      ApiConstants.endpoint(baseUrl, 'v1/patients/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete patient');
    }
  }

  Future<void> updatePatient(int id, UpdatePatientRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.put(
      ApiConstants.endpoint(baseUrl, 'v1/patients/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update patient');
    }
  }
}
