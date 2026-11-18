import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/update_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/services/patient_service.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/repository/patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository{
  final PatientService patientService;

  PatientRepositoryImpl(this.patientService);

  @override
  Future<List<Patient>> getPatients() async {
    final patientResponses = await patientService.getAllPatients();
    return patientResponses.map((response) => response.toDomain()).toList();
  }

  @override
  Future<void> createPatient(AddPatientRequest patient) async {
    await patientService.createPatient(patient);
  }

  @override
  Future<void> deletePatient(int id) async {
    await patientService.deletePatient(id);
  }

  @override
  Future<void> updatePatient(int id, UpdatePatientRequest patient) async {
    await patientService.updatePatient(id, patient);
  }
}