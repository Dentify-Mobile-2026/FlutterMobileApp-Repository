import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';

class MedicalHistoryResponse {
  final int id;
  final String description;
  final String record;
  final String diagnosis;
  final String medication;
  final String createdAt;
  final String? appointmentDate;
  final int? sourceAppointmentId;
  final bool annulled;
  final String? annulmentReason;
  final String? annulledAt;

  const MedicalHistoryResponse({
    required this.id,
    required this.description,
    required this.record,
    required this.diagnosis,
    required this.medication,
    required this.createdAt,
    this.appointmentDate,
    this.sourceAppointmentId,
    this.annulled = false,
    this.annulmentReason,
    this.annulledAt,
  });

  factory MedicalHistoryResponse.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryResponse(
        id: json['id'],
        description: json['description'],
        record: json['record'],
        diagnosis: json['diagnosis'],
        medication: json['medication'],
        createdAt: json['createdAt'],
        appointmentDate: json['appointmentDate'],
        sourceAppointmentId: json['sourceAppointmentId'],
        // Las entradas anteriores a la anulación no traen el campo: cuentan como vigentes.
        annulled: json['annulled'] == true,
        annulmentReason: json['annulmentReason'],
        annulledAt: json['annulledAt']);
  }

  MedicalHistory toDomain() {
    return MedicalHistory(
        id: id,
        description: description,
        record: record,
        diagnosis: diagnosis,
        medication: medication,
        createdAt: createdAt,
        appointmentDate: appointmentDate,
        sourceAppointmentId: sourceAppointmentId,
        annulled: annulled,
        annulmentReason: annulmentReason,
        annulledAt: annulledAt);
  }
}
