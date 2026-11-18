import 'dart:convert';
import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/model/treatment_response.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/remote/dto/treatment_request.dart';
import 'package:http/http.dart' as http;

class TreatmentService {
  final String baseUrl;

  TreatmentService(this.baseUrl);

  Future<List<TreatmentResponse>> getAllTreatments() async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      ApiConstants.endpoint(baseUrl, 'v1/treatments'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((item) => TreatmentResponse.fromJson(item))
          .toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load treatments');
    }
  }

  Future<void> createTreatment(TreatmentRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      ApiConstants.endpoint(baseUrl, 'v1/treatments'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 201) {
      try {
        final Map<String, dynamic> err = json.decode(response.body);
        if (err.containsKey('error')) throw Exception(err['error']);
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) rethrow;
      }
      throw Exception('Failed to create treatment');
    }
  }

  Future<void> updateTreatment(int id, TreatmentRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.put(
      ApiConstants.endpoint(baseUrl, 'v1/treatments/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update treatment');
    }
  }

  Future<void> deleteTreatment(int id) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      ApiConstants.endpoint(baseUrl, 'v1/treatments/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete treatment');
    }
  }
}
