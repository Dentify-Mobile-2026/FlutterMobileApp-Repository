import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/repository/medical_history_repository.dart';

/// Anula una entrada de la historia clínica con un motivo (US18).
class AnnulMedicalHistoryUseCase {
  final MedicalHistoryRepository medicalHistoryRepository;

  AnnulMedicalHistoryUseCase(this.medicalHistoryRepository);

  Future<MedicalHistory> call(int patientId, int medicalHistoryId, String reason) {
    return medicalHistoryRepository.annulMedicalHistory(patientId, medicalHistoryId, reason);
  }
}
