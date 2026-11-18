import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/repository/patient_repository.dart';

class GetAllPatientsUseCase {
  final PatientRepository patientRepository;

  GetAllPatientsUseCase(this.patientRepository);

  Future<List<Patient>> call() {
    return patientRepository.getPatients();
  }
}