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

    final response = await http
        .get(
          ApiConstants.endpoint(baseUrl, 'v1/patients'),
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
          .map((patient) => PatientResponse.fromJson(patient))
          .toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error al cargar pacientes (${response.statusCode})');
    }
  }

  Future<void> createPatient(AddPatientRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http
        .post(
          ApiConstants.endpoint(baseUrl, 'v1/patients'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      _throwResponseError(response, 'Error al registrar paciente');
    }
  }

  Future<void> deletePatient(int id) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http
        .delete(
          ApiConstants.endpoint(baseUrl, 'v1/patients/$id'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 204) {
      _throwResponseError(response, 'No se pudo eliminar el paciente');
    }
  }

  Future<void> updatePatient(int id, UpdatePatientRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http
        .put(
          ApiConstants.endpoint(baseUrl, 'v1/patients/$id'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      _throwResponseError(response, 'No se pudo actualizar el paciente');
    }
  }

  Never _throwResponseError(http.Response response, String fallback) {
    try {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic> && decoded['error'] != null) {
        throw Exception(decoded['error'].toString());
      }
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) {
        rethrow;
      }
    }
    throw Exception('$fallback (${response.statusCode})');
  }
}
