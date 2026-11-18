class UpdateAppointmentStatusRequest {
  final String status;
  final String clinicalNotes;

  const UpdateAppointmentStatusRequest({
    required this.status,
    this.clinicalNotes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'clinicalNotes': clinicalNotes,
    };
  }
}
