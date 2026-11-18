import 'dart:convert';
import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:http/http.dart' as http;
import '../dto/login_request.dart';
import '../dto/register_request.dart';
import '../../model/login_response.dart';
import '../../model/register_response.dart';

class AuthApiService {
  final String baseUrl;
  final http.Client? _client;

  AuthApiService(this.baseUrl, {http.Client? client}) : _client = client;

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    final request = _client?.post ?? http.post;
    final response = await request(
      ApiConstants.endpoint(baseUrl, 'auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(loginRequest.toJson()),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Login failed (HTTP ${response.statusCode}).');
    }
  }

  Future<RegisterResponse> register(RegisterRequest registerRequest) async {
    final request = _client?.post ?? http.post;
    final response = await request(
      ApiConstants.endpoint(baseUrl, 'auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(registerRequest.toJson()),
    );

    if (response.statusCode == 200) {
      return RegisterResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Registration failed (HTTP ${response.statusCode}).');
    }
  }
}
