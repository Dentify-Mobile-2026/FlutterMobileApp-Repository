import 'package:dentify_flutter/patientAttention/patients/data/di/dependency_injection.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/add_medical_history_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/add_patient_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/delete_patient_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/get_all_medical_histories_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/get_all_patients_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/update_patient_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/viewmodel/medical_history_view_model.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/viewmodel/patient_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final getAllPatientsUseCaseProvider = Provider<GetAllPatientsUseCase>((ref) {
  return GetAllPatientsUseCase(ref.read(patientRepositoryProvider));
});

final addPatientUseCaseProvider = Provider<AddPatientUseCase>((ref) {
  return AddPatientUseCase(ref.read(patientRepositoryProvider));
});

final deletePatientUseCaseProvider = Provider<DeletePatientUseCase>((ref) {
  return DeletePatientUseCase(ref.read(patientRepositoryProvider));
});

final updatePatientUseCaseProvider = Provider<UpdatePatientUseCase>((ref) {
  return UpdatePatientUseCase(ref.read(patientRepositoryProvider));
});

final patientsViewModelProvider = StateNotifierProvider<PatientViewModel, List<Patient>>((ref) {
  return PatientViewModel(
    ref.read(getAllPatientsUseCaseProvider), 
    ref.read(addPatientUseCaseProvider),
    ref.read(deletePatientUseCaseProvider),
    ref.read(updatePatientUseCaseProvider),
    ref
    );
});





final patientSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredPatientsProvider = Provider<List<Patient>>((ref) {
  final patients = ref.watch(patientsViewModelProvider);
  final query = ref.watch(patientSearchQueryProvider).toLowerCase();

  return patients.where((p) {
    return p.dni.contains(query) ||
           p.firstName.toLowerCase().contains(query) ||
           p.lastName.toLowerCase().contains(query);
  }).toList();
});




final getAllMedicalHistoriesUseCaseProvider = Provider<GetAllMedicalHistoriesUseCase>((ref) {
  return GetAllMedicalHistoriesUseCase(ref.read(medicalHistoryRepositoryProvider));
});

final addMedicalHistoryUseCaseProvider = Provider<AddMedicalHistoryUseCase>((ref) {
  return AddMedicalHistoryUseCase(ref.read(medicalHistoryRepositoryProvider));
});

final medicalHistoriesViewModelProvider = StateNotifierProvider.family<
  MedicalHistoryViewModel,
  List<MedicalHistory>,
  int 
>((ref, id) {
  return MedicalHistoryViewModel(
    ref.read(getAllMedicalHistoriesUseCaseProvider),
    ref.read(addMedicalHistoryUseCaseProvider),
    id,
  );
});


final isLoadingProvider = StateProvider<bool>((ref) => true);
