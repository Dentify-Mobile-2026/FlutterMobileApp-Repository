import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/model/appointment_response.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/add_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/patient_data_form.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AppointmentService {
  final String baseUrl;

  AppointmentService(this.baseUrl);

  Future<AppointmentResponse> getAppointmentById(int id) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      ApiConstants.endpoint(baseUrl, 'v1/appointments/appointment/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return AppointmentResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load appointment');
    }
  }

  Future<List<AppointmentResponse>> getAllAppointments() async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      ApiConstants.endpoint(baseUrl, 'v1/appointments'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("BODY: ${response.body}");
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((appointment) => AppointmentResponse.fromJson(appointment))
          .toList();
    } else {
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      throw Exception('Failed to load appointments');
    }
  }

  Future<void> createAppointment(AddAppointmentRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      ApiConstants.endpoint(baseUrl, 'v1/appointments'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create appointment');
    }
  }

  Future<void> updateAppointment(
    int id,
    UpdateAppointmentRequest request,
  ) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.put(
      ApiConstants.endpoint(baseUrl, 'v1/appointments/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update appointment');
    }
  }

  Future<void> deleteAppointment(int id) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      ApiConstants.endpoint(baseUrl, 'v1/appointments/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete appointment');
    }
  }

  Future<List<PatientDataForm>> getPatients() async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      ApiConstants.endpoint(baseUrl, 'v1/patients'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((patient) => PatientDataForm.fromJson(patient))
          .toList();
    } else {
      throw Exception('Failed to load patients');
    }
  }
}
