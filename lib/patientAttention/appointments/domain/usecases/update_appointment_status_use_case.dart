import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_status_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';

class UpdateAppointmentStatusUseCase {
  final AppointmentRepository repository;

  UpdateAppointmentStatusUseCase(this.repository);

  Future<void> call(int id, UpdateAppointmentStatusRequest request) {
    return repository.updateAppointmentStatus(id, request);
  }
}
