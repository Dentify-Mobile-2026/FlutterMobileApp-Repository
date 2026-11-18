import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';

class MedicalHistoryResponse {
  final int id;
  final String description;
  final String record;
  final String diagnosis;
  final String medication;
  final String createdAt;

  const MedicalHistoryResponse({
      required this.id,
      required this.description,
      required this.record,
      required this.diagnosis,
      required this.medication,
      required this.createdAt
  });

  factory MedicalHistoryResponse.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryResponse(
      id: json['id'], 
      description: json['description'], 
      record: json['record'], 
      diagnosis: json['diagnosis'], 
      medication: json['medication'], 
      createdAt: json['createdAt']);
  }

  MedicalHistory toDomain() {
    return MedicalHistory(
      id: id, 
      description: description, 
      record: record, 
      diagnosis: diagnosis, 
      medication: medication, 
      createdAt: createdAt);
  }
}
