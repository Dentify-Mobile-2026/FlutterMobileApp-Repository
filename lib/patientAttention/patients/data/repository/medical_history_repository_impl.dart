import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_medical_history_request.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/services/medical_history_service.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/repository/medical_history_repository.dart';

class MedicalHistoryRepositoryImpl implements MedicalHistoryRepository{
  final MedicalHistoryService medicalHistoryService;

  MedicalHistoryRepositoryImpl(this.medicalHistoryService);

  @override
  Future<List<MedicalHistory>> getMedicalHistories(int id) async {
    final medicalHistoryResponses = await medicalHistoryService.getAllMedicalHistories(id);
    return medicalHistoryResponses.map((response) => response.toDomain()).toList();
  }

  @override
  Future<void> createMedicalHistory(AddMedicalHistoryRequest medicalHistory, int id) async {
    await medicalHistoryService.createMedicalHistory(medicalHistory, id);
  }
} 