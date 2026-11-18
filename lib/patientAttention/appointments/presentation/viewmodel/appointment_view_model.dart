import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/add_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_status_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment_conflict_exception.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/add_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/delete_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_all_appointments_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_all_patients_data_form_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_appointment_by_id_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/update_appointment_status_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/update_appointment_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentViewModel extends StateNotifier<List<Appointment>> {
  final GetAllAppointmentsUseCase getAllAppointmentsUseCase;
  final GetAppointmentByIdUseCase getAppointmentByIdUseCase;
  final AddAppointmentUseCase addAppointmentUseCase;
  final UpdateAppointmentUseCase updateAppointmentUseCase;
  final UpdateAppointmentStatusUseCase updateAppointmentStatusUseCase;
  final DeleteAppointmentUseCase deleteAppointmentUseCase;
  final GetAllPatientsDataFormUseCase getAllPatientsDataFormUseCase;
  String? errorMessage;
  bool isLoading = true;

  AppointmentViewModel(
    this.getAllAppointmentsUseCase,
    this.getAppointmentByIdUseCase,
    this.addAppointmentUseCase,
    this.updateAppointmentUseCase,
    this.updateAppointmentStatusUseCase,
    this.deleteAppointmentUseCase,
    this.getAllPatientsDataFormUseCase,
  ) : super([]) {
    getAllAppointments();
  }

  Future<void> getAllAppointments() async {
    try {
      errorMessage = null;
      isLoading = true;
      final appointments = await getAllAppointmentsUseCase();
      state = appointments;
    } catch (e) {
      errorMessage = e.toString();
      state = [];
    } finally {
      isLoading = false;
    }
  }

  Future<void> getAppointmentById(int id) async {
    try {
      errorMessage = null;
      final appointment = await getAppointmentByIdUseCase(id);
      state = [appointment];
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<String?> addAppointment(AddAppointmentRequest newAppointment) async {
    try {
      errorMessage = null;
      await addAppointmentUseCase(newAppointment);
      await getAllAppointments();
      return null;
    } on AppointmentConflictException catch (e) {
      return e.message;
    } catch (e) {
      errorMessage = e.toString();
      return 'Could not save the appointment. Please try again.';
    }
  }

  Future<String?> updateAppointment(
      int id, UpdateAppointmentRequest appointment) async {
    try {
      errorMessage = null;
      await updateAppointmentUseCase(id, appointment);
      await getAllAppointments();
      return null;
    } on AppointmentConflictException catch (e) {
      return e.message;
    } catch (e) {
      errorMessage = e.toString();
      return 'Could not update the appointment. Please try again.';
    }
  }

  Future<String?> updateAppointmentStatus(
      int id, UpdateAppointmentStatusRequest request) async {
    try {
      errorMessage = null;
      await updateAppointmentStatusUseCase(id, request);
      await getAllAppointments();
      return null;
    } catch (e) {
      errorMessage = e.toString();
      return 'Could not update appointment status.';
    }
  }

  Future<void> deleteAppointment(int id) async {
    try {
      errorMessage = null;
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
    }
  }
}
