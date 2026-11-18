import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';

class GetAppointmentByIdUseCase {
  final AppointmentRepository _repository;

  GetAppointmentByIdUseCase(this._repository);

  Future<Appointment> call(int id) {
    return _repository.getAppointmentById(id);
  }
}
