

class UpdateAppointmentRequest {
  final String appointmentDate;
  final String reason;
  final String duration;

  UpdateAppointmentRequest({
    required this.appointmentDate,
    required this.reason,
    required this.duration,
  });

  // Convert from UpdateAppointmentRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'appointmentDate': appointmentDate,
      'reason': reason,
      'duration': duration,
    };
  }
}