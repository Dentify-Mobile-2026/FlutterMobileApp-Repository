
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';

class AppointmentResponse {
  final int id;
  final String patientName;
  final String dni;
  final String appointmentDate;
  final String reason;
  final bool completed;
  final String duration;
  final String createdAt;

  AppointmentResponse(
      {required this.id,
      required this.patientName,
      required this.dni,
      required this.appointmentDate,
      required this.reason,
      required this.completed,
      required this.duration,
      required this.createdAt});


  // Convert from JSON to AppointmentResponse
  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentResponse(
      id: json['id'],
      patientName: json['patientName'],
      dni: json['dni'],
      appointmentDate: json['appointmentDate'],
      reason: json['reason'],
      completed: json['completed'],
      duration: json['duration'],
      createdAt: json['createdAt'],
    );
  }
  // Convert from AppointmentResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'dni': dni,
      'appointmentDate': appointmentDate,
      'reason': reason,
      'completed': completed,
      'duration': duration,
      'createdAt': createdAt,
    };
  }


  Appointment toDomain() {
    return Appointment(
        id: id,
        patientName: patientName,
        dni: dni,
        appointmentDate: appointmentDate,
        reason: reason,
        completed: completed,
        duration: duration,
        createdAt: createdAt);
  }
}