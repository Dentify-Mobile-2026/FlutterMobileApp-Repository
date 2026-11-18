class AddMedicalHistoryRequest {
  final String description;
  final String record;
  final String diagnosis;
  final String medication;

  const AddMedicalHistoryRequest({
    required this.description,
    required this.record,
    required this.diagnosis,
    required this.medication});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'record': record,
      'diagnosis': diagnosis,
      'medication': medication,
    };
  }
}