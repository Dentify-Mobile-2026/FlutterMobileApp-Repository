import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_medical_history_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/repository/medical_history_repository.dart';

class AddMedicalHistoryUseCase {
  final MedicalHistoryRepository medicalHistoryRepository;

  AddMedicalHistoryUseCase(this.medicalHistoryRepository);

  Future<void> call(AddMedicalHistoryRequest medicalHistory, int id) {
    return medicalHistoryRepository.createMedicalHistory(medicalHistory, id);
  }
}