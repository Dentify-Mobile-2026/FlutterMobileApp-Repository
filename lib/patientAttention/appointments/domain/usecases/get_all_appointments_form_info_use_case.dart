import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';

class GetAllAppointmentsFormInfoUseCase {
  final AppointmentRepository appointmentRepository;

  GetAllAppointmentsFormInfoUseCase(this.appointmentRepository);

  Future<List<Appointment>> call() {
    return appointmentRepository.getAppointments();
  }
}
