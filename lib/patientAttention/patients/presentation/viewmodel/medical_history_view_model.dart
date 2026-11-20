import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_medical_history_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/add_medical_history_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/get_all_medical_histories_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicalHistoryViewModel extends StateNotifier<List<MedicalHistory>> {
  final GetAllMedicalHistoriesUseCase getAllMedicalHistoriesUseCase;
  final AddMedicalHistoryUseCase addMedicalHistoryUseCase;
  String? errorMessage;
  bool isLoading = true;

  MedicalHistoryViewModel(
      this.getAllMedicalHistoriesUseCase, this.addMedicalHistoryUseCase, int id)
      : super([]) {
    getAllMedicalHistories(id);
  }

  Future<void> getAllMedicalHistories(int id) async {
    try {
      errorMessage = null;
      isLoading = true;
      final medicalHistories = await getAllMedicalHistoriesUseCase(id);
      if (!mounted) return;
      isLoading = false;
      state = medicalHistories;
    } catch (e) {
      if (!mounted) return;
      errorMessage = e.toString();
      isLoading = false;
      state = [];
    } finally {
      isLoading = false;
    }
  }

  Future<void> addMedicalHistory(
      AddMedicalHistoryRequest newMedicalHistory, int id) async {
    try {
      errorMessage = null;
      await addMedicalHistoryUseCase(newMedicalHistory, id);
      if (!mounted) return;
      await getAllMedicalHistories(id); // recargar
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}
