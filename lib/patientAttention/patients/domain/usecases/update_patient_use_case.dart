import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/update_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/repository/patient_repository.dart';

class UpdatePatientUseCase {
  final PatientRepository patientRepository;

  UpdatePatientUseCase(this.patientRepository);

  Future<void> call(int id, UpdatePatientRequest patient) {
    return patientRepository.updatePatient(id, patient);
  }
}