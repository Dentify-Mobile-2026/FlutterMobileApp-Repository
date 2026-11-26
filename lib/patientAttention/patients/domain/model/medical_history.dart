class MedicalHistory {
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

  const MedicalHistory({
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
}
