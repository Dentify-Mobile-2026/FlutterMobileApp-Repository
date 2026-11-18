import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/repository/medical_history_repository.dart';

class GetAllMedicalHistoriesUseCase {
  final MedicalHistoryRepository medicalHistoryRepository;

  GetAllMedicalHistoriesUseCase(this.medicalHistoryRepository);

  Future<List<MedicalHistory>> call(int id) {
    return medicalHistoryRepository.getMedicalHistories(id);
  }
}