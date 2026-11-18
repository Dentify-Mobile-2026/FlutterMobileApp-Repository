import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/add_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';

class AddAppointmentUseCase {
  final AppointmentRepository _repository;

  AddAppointmentUseCase(this._repository);

  Future<void> call(AddAppointmentRequest appointment) {
    return _repository.createAppointment(appointment);
  }
}