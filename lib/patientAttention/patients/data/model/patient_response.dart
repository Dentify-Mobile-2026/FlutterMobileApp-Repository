import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';

class PatientResponse {
  final int id;
  final String dni;
  final String firstName;
  final String lastName;
  final String email;
  final String homeAddress;
  final String birthday;

  const PatientResponse({
    required this.id,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.homeAddress,
    required this.birthday
  });

  factory PatientResponse.fromJson(Map<String, dynamic> json) {
    return PatientResponse(
      id: json['id'], 
      dni: json['dni'], 
      firstName: json['firstName'], 
      lastName: json['lastName'], 
      email: json['email'], 
      homeAddress: json['homeAddress'], 
      birthday: json['birthday']);
  }

  Patient toDomain() {
    return Patient(
      id: id, 
      dni: dni, 
      firstName: firstName, 
      lastName: lastName, 
      email: email, 
      homeAddress: homeAddress, 
      birthday: birthday);
  }
}