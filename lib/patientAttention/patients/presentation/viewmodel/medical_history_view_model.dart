import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_medical_history_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/add_medical_history_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/get_all_medical_histories_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicalHistoryViewModel extends StateNotifier<List<MedicalHistory>>{
  final GetAllMedicalHistoriesUseCase getAllMedicalHistoriesUseCase;
  final AddMedicalHistoryUseCase addMedicalHistoryUseCase;
  String? errorMessage;
  bool isLoading = true;

  MedicalHistoryViewModel(
    this.getAllMedicalHistoriesUseCase,
    this.addMedicalHistoryUseCase,
    int id
  ): super([]) {
    getAllMedicalHistories(id);
  }

  Future<void> getAllMedicalHistories(int id) async {
    try {
      isLoading = true;
      final medicalHistories = await getAllMedicalHistoriesUseCase(id);
      state = medicalHistories;
    } catch (e) {
      errorMessage = e.toString();
      state = [];
      print('Error fetching medical histories: $errorMessage');
    } finally {
      isLoading = false;
    }
  }

  Future<void> addMedicalHistory(AddMedicalHistoryRequest newMedicalHistory, int id) async {
    try {
      await addMedicalHistoryUseCase(newMedicalHistory, id);
      await getAllMedicalHistories(id); // recargar
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}