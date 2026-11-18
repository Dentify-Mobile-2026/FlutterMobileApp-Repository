import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';

class PatientResponse {
  final int id;
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

  const PatientResponse({
    required this.id,
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

  factory PatientResponse.fromJson(Map<String, dynamic> json) {
    return PatientResponse(
      id: json['id'],
      dni: (json['dni'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      homeAddress: (json['homeAddress'] ?? '').toString(),
      birthday: (json['birthday'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      allergies: (json['allergies'] ?? '').toString(),
      systemicConditions: (json['systemicConditions'] ?? '').toString(),
      emergencyContactName: (json['emergencyContactName'] ?? '').toString(),
      emergencyContactPhone: (json['emergencyContactPhone'] ?? '').toString(),
    );
  }

  Patient toDomain() {
    return Patient(
      id: id,
      dni: dni,
      firstName: firstName,
      lastName: lastName,
      email: email,
      homeAddress: homeAddress,
      birthday: birthday,
      phone: phone,
      allergies: allergies,
      systemicConditions: systemicConditions,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
    );
  }
}
