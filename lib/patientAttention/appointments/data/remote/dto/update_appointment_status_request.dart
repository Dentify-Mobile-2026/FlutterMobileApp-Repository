class UpdateAppointmentStatusRequest {
  final String status;
  final String clinicalNotes;
  final bool recordInMedicalHistory;

  const UpdateAppointmentStatusRequest({
    required this.status,
    this.clinicalNotes = '',
    this.recordInMedicalHistory = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'clinicalNotes': clinicalNotes,
      'recordInMedicalHistory': recordInMedicalHistory,
    };
  }
}
