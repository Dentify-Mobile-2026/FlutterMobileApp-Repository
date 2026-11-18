class UpdateInformationRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String companyName;

  UpdateInformationRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.companyName,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'companyName': companyName,
    };
  }
}
