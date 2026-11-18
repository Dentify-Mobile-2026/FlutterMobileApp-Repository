import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';

class UpdateAppointmentUseCase {
  final AppointmentRepository _repository;

  UpdateAppointmentUseCase(this._repository);

  Future<void> call(int id, UpdateAppointmentRequest appointment) {
    return _repository.updateAppointment(id, appointment);
  }
}