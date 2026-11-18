import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/add_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/dto/update_patient_request.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';

abstract class PatientRepository {
    Future<List<Patient>> getPatients();
    Future<void> createPatient(AddPatientRequest patient);
    Future<void> deletePatient(int id);
    Future<void> updatePatient(int id, UpdatePatientRequest patient);
}