import 'package:dentify_flutter/patientAttention/appointments/domain/model/patient_data_form.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/patient_repository.dart';

class GetAllPatientsDataFormUseCase {
  final PatientRepository _repository;

  GetAllPatientsDataFormUseCase(this._repository);

  Future<List<PatientDataForm>> call() async {
    return await _repository.getPatients();
  }
}