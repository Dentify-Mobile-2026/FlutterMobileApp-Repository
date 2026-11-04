class ApiConstants {
  static const String baseUrl =
      "https://backend-repository-8k4q.onrender.com/api/";

  static Uri endpoint(String baseUrl, String path) {
    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    return Uri.parse(normalizedBaseUrl).resolve(path);
  }
}
