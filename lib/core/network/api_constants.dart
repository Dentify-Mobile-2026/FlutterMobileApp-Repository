class ApiConstants {
  /// URL del servicio web. Se puede cambiar al compilar: --dart-define=API_BASE_URL=http://localhost:8080/api/
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: "http://localhost:8080/api/",
  );

  static Uri endpoint(String baseUrl, String path) {
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(normalizedBaseUrl).resolve(path);
  }
}
