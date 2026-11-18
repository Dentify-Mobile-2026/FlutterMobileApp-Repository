import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment_status.dart';

class Appointment {
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

  Appointment({
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

  AppointmentStatus get statusEnum =>
      AppointmentStatus.fromCode(status, fallbackCompleted: completed);
}
