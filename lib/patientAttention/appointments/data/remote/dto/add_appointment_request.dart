
class AddAppointmentRequest {
  final String appointmentDate;
  final String reason;
  final String duration;
  final int patientId;

  AddAppointmentRequest({
    required this.appointmentDate,
    required this.reason,
    required this.duration,
    required this.patientId,
  });

  // Convert from AddAppointmentRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'appointmentDate': appointmentDate,
      'reason': reason,
      'duration': duration,
      'patientId': patientId,
    };
  }
}