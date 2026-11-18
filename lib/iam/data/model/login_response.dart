
class LoginResponse {
  final String accessToken;
  final String refreshToken;

  // Constructor con parámetros nombrados
  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  // Convertir de JSON a LoginResponse
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  // Convertir de LoginResponse a JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
