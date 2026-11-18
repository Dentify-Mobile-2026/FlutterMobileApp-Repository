import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';

class AppointmentDataForm {
  final int id;
  final String patientName;
  final String reason;
  final bool completed;

  AppointmentDataForm({
    required this.id,
    required this.patientName,
    required this.reason,
    required this.completed,
  });

  // Métodos para convertir a un mapa (para serialización, si es necesario)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'reason': reason,
      'completed': completed,
    };
  }

  // Método estático para crear la instancia desde un mapa
  factory AppointmentDataForm.fromJson(Map<String, dynamic> json) {
    return AppointmentDataForm(
      id: json['id'],
      patientName: json['patientName'],
      reason: json['reason'],
      completed: json['completed'],
    );
  }

  factory AppointmentDataForm.fromAppointment(Appointment appointment) {
    return AppointmentDataForm(
      id: appointment.id,
      patientName: appointment.patientName,
      reason: appointment.reason,
      completed: appointment.completed,
    );
  }

}
