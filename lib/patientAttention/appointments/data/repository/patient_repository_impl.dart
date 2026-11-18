import 'package:dentify_flutter/patientAttention/appointments/data/remote/services/appointment_service.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/patient_data_form.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  final AppointmentService appointmentService;
  PatientRepositoryImpl(this.appointmentService);

  @override
  Future<List<PatientDataForm>> getPatients() async {
     return await appointmentService.getPatients();
  }
}