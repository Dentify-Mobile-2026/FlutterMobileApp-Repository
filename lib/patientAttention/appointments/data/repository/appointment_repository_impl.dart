import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/add_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/services/appointment_service.dart';

class AppointmentRepositoryImpl implements AppointmentRepository{
  final AppointmentService appointmentService;

  AppointmentRepositoryImpl(this.appointmentService);

  @override
  Future<List<Appointment>> getAppointments() async {
    final appointmentResponses = await appointmentService.getAllAppointments();
    return appointmentResponses.map((response) => response.toDomain()).toList();
  }

  @override
  Future<Appointment> getAppointmentById(int id) async {
    final appointmentResponse = await appointmentService.getAppointmentById(id);
    return appointmentResponse.toDomain();
  }

  @override
  Future<void> createAppointment(AddAppointmentRequest appointment) async {
    await appointmentService.createAppointment(appointment);
  }

  @override
  Future<void> updateAppointment(int id, UpdateAppointmentRequest appointment) async {
    await appointmentService.updateAppointment(id, appointment);
  }
  
  @override
  Future<void> deleteAppointment(int id) async {
    await appointmentService.deleteAppointment(id);
  }

}