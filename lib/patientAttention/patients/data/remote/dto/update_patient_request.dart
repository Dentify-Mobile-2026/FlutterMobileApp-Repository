class UpdatePatientRequest {
  final int dni;
  final String firstName;
  final String lastName;
  final String email;
  final String homeAddress;
  final String birthday;

  const UpdatePatientRequest({
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.homeAddress,
    required this.birthday
  });

  Map<String, dynamic> toJson() {
    return {
      'dni': dni,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'homeAddress': homeAddress,
      'birthday': birthday
    };
  }
}