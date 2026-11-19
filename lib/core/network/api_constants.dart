import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  /// Constante para anotaciones `@RestApi(...)`. En tiempo de ejecución se usa `baseUrl`.
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/',
  );

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// URL del servicio web:
  /// - Si se pasa `--dart-define=API_BASE_URL=...`, se respeta siempre.
  /// - En Web (incluyendo iPhone por red local), usa automáticamente el mismo host donde se abrió la app en el puerto 8080.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty) {
        return '${Uri.base.scheme}://$host:8080/api/';
      }
    }
    return defaultBaseUrl;
  }

  static Uri endpoint(String baseUrl, String path) {
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(normalizedBaseUrl).resolve(path);
  }
}
