import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_medical_history_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';

abstract class MedicalHistoryRepository {
  Future<List<MedicalHistory>> getMedicalHistories(int id);
  Future<void> createMedicalHistory(AddMedicalHistoryRequest medicalHistory, int id);
}