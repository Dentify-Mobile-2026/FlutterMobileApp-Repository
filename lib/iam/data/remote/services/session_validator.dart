import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:http/http.dart' as http;

enum SessionStatus { valid, invalid, unknown }

/// Comprueba con el servicio si el token guardado sigue siendo válido.
///
/// Un token vencido, firmado para otra base o de un usuario que ya no existe responde 401
/// (o 403): la sesión es inválida y hay que volver a iniciarla. Sin conexión o ante otro
/// error la respuesta es `unknown`, para no cerrar la sesión por un corte de red.
class SessionValidator {
  final String baseUrl;
  final http.Client? _client;
  final Duration timeout;

  SessionValidator(this.baseUrl, {http.Client? client, this.timeout = const Duration(seconds: 8)})
      : _client = client;

  Future<SessionStatus> check(String accessToken) async {
    try {
      final get = _client?.get ?? http.get;
      final response = await get(
        ApiConstants.endpoint(baseUrl, 'v1/profile'),
        headers: {'Authorization': 'Bearer $accessToken'},
      ).timeout(timeout);
      if (response.statusCode == 200) return SessionStatus.valid;
      if (response.statusCode == 401 || response.statusCode == 403) return SessionStatus.invalid;
      return SessionStatus.unknown;
    } catch (_) {
      return SessionStatus.unknown;
    }
  }
}
