import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';

class DeleteAppointmentUseCase {
  final AppointmentRepository _repository;

  DeleteAppointmentUseCase(this._repository);

  Future<void> call(int id) async {
    await _repository.deleteAppointment(id);
  }
}