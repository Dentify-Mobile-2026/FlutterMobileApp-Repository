import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';

class AppointmentResponse {
  final int id;
  final String patientName;
  final String dni;
  final String patientPhone;
  final String appointmentDate;
  final String reason;
  final bool completed;
  final String status;
  final String clinicalNotes;
  final int? treatmentId;
  final String treatmentName;
  final String duration;
  final String createdAt;

  AppointmentResponse({
    required this.id,
    required this.patientName,
    required this.dni,
    this.patientPhone = '',
    required this.appointmentDate,
    required this.reason,
    required this.completed,
    this.status = 'SCHEDULED',
    this.clinicalNotes = '',
    this.treatmentId,
    this.treatmentName = '',
    required this.duration,
    required this.createdAt,
  });

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    final bool isCompleted = json['completed'] ?? false;
    return AppointmentResponse(
      id: json['id'],
      patientName: (json['patientName'] ?? '').toString(),
      dni: (json['dni'] ?? '').toString(),
      patientPhone: (json['patientPhone'] ?? '').toString(),
      appointmentDate: (json['appointmentDate'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      completed: isCompleted,
      status: (json['status'] ?? (isCompleted ? 'COMPLETED' : 'SCHEDULED')).toString(),
      clinicalNotes: (json['clinicalNotes'] ?? '').toString(),
      treatmentId: (json['treatmentId'] as num?)?.toInt(),
      treatmentName: (json['treatmentName'] ?? '').toString(),
      duration: (json['duration'] ?? '00:30').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'dni': dni,
      'patientPhone': patientPhone,
      'appointmentDate': appointmentDate,
      'reason': reason,
      'completed': completed,
      'status': status,
      'clinicalNotes': clinicalNotes,
      'treatmentId': treatmentId,
      'treatmentName': treatmentName,
      'duration': duration,
      'createdAt': createdAt,
    };
  }

  Appointment toDomain() {
    return Appointment(
      id: id,
      patientName: patientName,
      dni: dni,
      patientPhone: patientPhone,
      appointmentDate: appointmentDate,
      reason: reason,
      completed: completed,
      status: status,
      clinicalNotes: clinicalNotes,
      treatmentId: treatmentId,
      treatmentName: treatmentName,
      duration: duration,
      createdAt: createdAt,
    );
  }
}
