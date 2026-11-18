class AddAppointmentRequest {
  final String appointmentDate;
  final String reason;
  final String duration;
  final int patientId;
  final int? treatmentId;

  AddAppointmentRequest({
    required this.appointmentDate,
    required this.reason,
    required this.duration,
    required this.patientId,
    this.treatmentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointmentDate': appointmentDate,
      'reason': reason,
      'duration': duration,
      'patientId': patientId,
      if (treatmentId != null) 'treatmentId': treatmentId,
    };
  }
}
