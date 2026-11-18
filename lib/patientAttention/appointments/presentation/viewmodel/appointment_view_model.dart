import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/add_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/add_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/delete_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_all_appointments_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_all_patients_data_form_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_appointment_by_id_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/update_appointment_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentViewModel extends StateNotifier<List<Appointment>> {
  final GetAllAppointmentsUseCase getAllAppointmentsUseCase;
  final GetAppointmentByIdUseCase getAppointmentByIdUseCase;
  final AddAppointmentUseCase addAppointmentUseCase;
  final UpdateAppointmentUseCase updateAppointmentUseCase;
  final DeleteAppointmentUseCase deleteAppointmentUseCase;
  final GetAllPatientsDataFormUseCase getAllPatientsDataFormUseCase;
  String? errorMessage;

  AppointmentViewModel(this.getAllAppointmentsUseCase, this.getAppointmentByIdUseCase, this.addAppointmentUseCase, this.updateAppointmentUseCase, this.deleteAppointmentUseCase, this.getAllPatientsDataFormUseCase) : super([]) {
    getAllAppointments();
  }

  Future<void> getAllAppointments() async {
    try {
      final appointments = await getAllAppointmentsUseCase();
      state = appointments;
    } catch (e) {
      errorMessage = e.toString();
      state = []; // Reset state on error
      print('Error fetching appointments: $errorMessage');
    }
  }
  Future<void> getAppointmentById(int id) async {
    try {
      final appointment = await getAppointmentByIdUseCase(id);
      state = [appointment]; // Update state with the single appointment
    } catch (e) {
      errorMessage = e.toString();
      print('Error fetching appointment by ID: $errorMessage');
    }
  }

  Future<void> addAppointment(AddAppointmentRequest newAppointment) async {
    // Llamar usecase correspondiente
    try {
      await addAppointmentUseCase(newAppointment);
      await getAllAppointments(); // recargar
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> updateAppointment(int id, UpdateAppointmentRequest appointment) async {
    try {
      await updateAppointmentUseCase(id, appointment);
      await getAllAppointments();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> deleteAppointment(int id) async {
    try {
      await deleteAppointmentUseCase(id);
      await getAllAppointments();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> getAllPatientsDataForm() async {
    try {
      await getAllPatientsDataFormUseCase();
    } catch (e) {
      errorMessage = e.toString();
      print('Error fetching patients data form: $errorMessage');
    }
  }
}
