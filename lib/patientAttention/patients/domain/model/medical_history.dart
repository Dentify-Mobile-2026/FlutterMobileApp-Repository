class MedicalHistory {
  final int id;
  final String description;
  final String record;
  final String diagnosis;
  final String medication;
  final String createdAt;

  const MedicalHistory({
      required this.id,
      required this.description,
      required this.record,
      required this.diagnosis,
      required this.medication,
      required this.createdAt
  });
}