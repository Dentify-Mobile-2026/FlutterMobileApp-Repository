class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String companyName;
  final String username;
  final String password;
  final bool trial;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.companyName,
    required this.username,
    required this.password,
    required this.trial,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'companyName': companyName,
      'username': username,
      'password': password,
      'trial': trial,
    };
  }
}
