import 'dart:convert';
import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:http/http.dart' as http;
import '../dto/login_request.dart';
import '../dto/register_request.dart';
import '../../model/login_response.dart';
import '../../model/register_response.dart';

/// Error de autenticación con un mensaje listo para mostrar en pantalla.
class AuthApiException implements Exception {
  final String message;
  final int? statusCode;

  const AuthApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

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
    }
    throw AuthApiException(
      _errorMessage(response, 'No se pudo iniciar sesión'),
      statusCode: response.statusCode,
    );
  }

  Future<RegisterResponse> register(RegisterRequest registerRequest) async {
    final request = _client?.post ?? http.post;
    final response = await request(
      ApiConstants.endpoint(baseUrl, 'auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(registerRequest.toJson()),
    );

    // El servicio responde 201 Created al registrar; se acepta también 200.
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterResponse.fromJson(json.decode(response.body));
    }
    throw AuthApiException(
      _errorMessage(response, 'No se pudo crear la cuenta'),
      statusCode: response.statusCode,
    );
  }

  /// Usa el mensaje `{"error": "..."}` del servicio; si no viene, uno genérico con el código HTTP.
  static String _errorMessage(http.Response response, String fallback) {
    if (response.statusCode == 401) return 'Usuario o contraseña incorrectos.';
    try {
      final body = json.decode(response.body);
      if (body is Map && body['error'] is String && (body['error'] as String).trim().isNotEmpty) {
        return body['error'] as String;
      }
    } catch (_) {
      // Cuerpo vacío o no JSON: se usa el mensaje genérico.
    }
    return '$fallback (HTTP ${response.statusCode}).';
  }
}
