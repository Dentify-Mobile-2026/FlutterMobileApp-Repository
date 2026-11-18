import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/repository/patient_repository.dart';

class AddPatientUseCase {
  final PatientRepository patientRepository;

  AddPatientUseCase(this.patientRepository);

  Future<void> call(AddPatientRequest patient) {
    return patientRepository.createPatient(patient);
  }
}