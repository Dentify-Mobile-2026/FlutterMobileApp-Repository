import 'package:dentify_flutter/patientAttention/patients/domain/repository/patient_repository.dart';

class DeletePatientUseCase {
  final PatientRepository patientRepository;

  DeletePatientUseCase(this.patientRepository);

  Future<void> call(int id) async {
    await patientRepository.deletePatient(id);
  }
}