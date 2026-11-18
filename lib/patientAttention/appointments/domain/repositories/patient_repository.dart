import 'package:dentify_flutter/patientAttention/appointments/domain/model/patient_data_form.dart';

abstract class PatientRepository {
  Future<List<PatientDataForm>> getPatients();
}