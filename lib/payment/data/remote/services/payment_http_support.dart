import 'dart:convert';

import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:http/http.dart' as http;

/// Cabeceras comunes de la API de pagos, con el token Bearer de la sesión.
Future<Map<String, String>> paymentRequestHeaders() async {
  final token = await TokenStorage.getAccessToken();
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };
}

bool isSuccessStatus(int statusCode) => statusCode >= 200 && statusCode < 300;

/// Decodifica el cuerpo siempre como UTF-8 (el backend puede omitir el
/// charset y `http` asumiría latin1, rompiendo tildes y eñes).
Object? decodePaymentBody(http.Response response) {
  final text = utf8.decode(response.bodyBytes, allowMalformed: true).trim();
  if (text.isEmpty) return null;
  return json.decode(text);
}

/// Decodifica una respuesta de lista JSON. Un cuerpo vacío equivale a lista vacía.
List<Map<String, dynamic>> decodePaymentList(http.Response response) {
  final body = decodePaymentBody(response);
  if (body == null) return const [];
  if (body is! List) {
    throw const FormatException('Respuesta inesperada del servidor');
  }
  return body
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

/// Construye la excepción a partir de una respuesta no 2xx, usando el mensaje
/// del cuerpo `{"error": "..."}` cuando existe.
PaymentApiException paymentApiExceptionFrom(http.Response response) {
  final status = response.statusCode;
  String? serverMessage;
  try {
    final body = decodePaymentBody(response);
    // El cuerpo por defecto de Spring ({timestamp, status, error, path}) trae en
    // `error` solo la frase HTTP en inglés; en ese caso se usa el mensaje local.
    if (body is Map && !body.containsKey('timestamp')) {
      final error = body['error'];
      if (error is String && error.trim().isNotEmpty) {
        serverMessage = error.trim();
      }
    }
  } on FormatException {
    // Cuerpo no JSON: se usa el mensaje por defecto.
  }
  return PaymentApiException(status, serverMessage ?? _defaultMessage(status));
}

String _defaultMessage(int status) {
  if (status == 400) return 'Los datos enviados no son válidos.';
  if (status == 401 || status == 403) {
    return 'Tu sesión expiró o no tienes permisos. Inicia sesión nuevamente.';
  }
  if (status == 404) return 'No se encontró el recurso solicitado.';
  if (status == 409) return 'La cita ya tiene un comprobante registrado.';
  if (status >= 500) return 'Error del servidor. Intenta nuevamente en unos minutos.';
  return 'No se pudo completar la operación (HTTP $status).';
}
