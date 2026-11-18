import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/update_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/add_patient_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/delete_patient_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/get_all_patients_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/usecases/update_patient_use_case.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/di/presentation_module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientViewModel extends StateNotifier<List<Patient>> {
  final GetAllPatientsUseCase getAllPatientsUseCase;
  final AddPatientUseCase addPatientUseCase;
  final DeletePatientUseCase deletePatientUseCase;
  final UpdatePatientUseCase updatePatientUseCase;
  String? errorMessage;
  final Ref ref;

  PatientViewModel(
    this.getAllPatientsUseCase,
    this.addPatientUseCase,
    this.deletePatientUseCase,
    this.updatePatientUseCase,
    this.ref,
  ) : super([]) {
    getAllPatients();
  }

  Future<void> getAllPatients() async {
    try {
      ref.read(isLoadingProvider.notifier).state = true;
      final patients = await getAllPatientsUseCase();
      state = patients;
    } catch (e) {
      errorMessage = e.toString();
      state = [];
      print('Error fetching patients: $errorMessage');
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> addPatient(AddPatientRequest newPatient) async {
    try {
      await addPatientUseCase(newPatient);
      await getAllPatients(); // recargar
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> deletePatient(int id) async {
    try {
      await deletePatientUseCase(id);
      await getAllPatients();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> updatePatient(int id, UpdatePatientRequest patient) async {
    try {
      await updatePatientUseCase(id, patient);
      await getAllPatients();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<bool> deletePatientAndRefresh(int id) async {
    try {
      ref.read(isLoadingProvider.notifier).state = true;
      await deletePatientUseCase(id);
      await getAllPatients();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}
