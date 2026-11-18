class AddPatientRequest {
  final String dni;
  final String firstName;
  final String lastName;
  final String email;
  final String homeAddress;
  final String birthday;
  final String phone;
  final String allergies;
  final String systemicConditions;
  final String emergencyContactName;
  final String emergencyContactPhone;

  const AddPatientRequest({
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.homeAddress,
    required this.birthday,
    this.phone = '',
    this.allergies = '',
    this.systemicConditions = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'dni': dni,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'homeAddress': homeAddress,
      'birthday': birthday,
      'phone': phone,
      'allergies': allergies,
      'systemicConditions': systemicConditions,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
    };
  }
}
