class UserInfoResponse {
  final String fullName;
  final String username;
  final String email;
  final String companyName;

  UserInfoResponse({
    required this.fullName,
    required this.username,
    required this.email,
    required this.companyName,
  });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
      companyName: json['companyName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'companyName': companyName,
    };
  }
}
