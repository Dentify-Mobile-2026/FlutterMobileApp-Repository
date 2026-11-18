import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/add_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments();
  Future<Appointment> getAppointmentById(int id);
  Future<void> createAppointment(AddAppointmentRequest appointment);
  Future<void> updateAppointment(int id, UpdateAppointmentRequest appointment);
  Future<void> deleteAppointment(int id);
}