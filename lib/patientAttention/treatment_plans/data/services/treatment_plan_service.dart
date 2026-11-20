import 'dart:convert';
import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:http/http.dart' as http;

class TreatmentPlanService {
  final String baseUrl;
  final http.Client client;
  final Future<String?> Function() accessToken;
  TreatmentPlanService(this.baseUrl,
      {http.Client? client, Future<String?> Function()? accessToken})
      : client = client ?? http.Client(),
        accessToken = accessToken ?? TokenStorage.getAccessToken;

  Future<dynamic> request(String method, String path,
      [Map<String, dynamic>? body]) async {
    final token = await accessToken();
    final request =
        http.Request(method, ApiConstants.endpoint(baseUrl, 'v1/$path'));
    request.headers.addAll({
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'
    });
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(await client.send(request));
    final text = utf8.decode(response.bodyBytes);
    dynamic data;
    try {
      data = text.isEmpty ? null : jsonDecode(text);
    } on FormatException {
      data = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map
          ? data['error'] ?? data['detail'] ?? data['message']
          : null;
      throw Exception(message ??
          'No se pudo guardar o cargar el plan (${response.statusCode}).');
    }
    return data;
  }

  void close() => client.close();
}
