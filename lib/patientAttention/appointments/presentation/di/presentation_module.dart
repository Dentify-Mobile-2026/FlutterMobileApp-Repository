import 'package:dentify_flutter/patientAttention/appointments/data/di/dependency_injection.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/add_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/delete_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_all_appointments_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_all_patients_data_form_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_appointment_by_id_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/update_appointment_status_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/update_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/viewmodel/appointment_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllAppointmentsUseCaseProvider = Provider<GetAllAppointmentsUseCase>((ref) {
  return GetAllAppointmentsUseCase(ref.read(appointmentRepositoryProvider));
});

final getAppointmentByIdUseCaseProvider = Provider<GetAppointmentByIdUseCase>((ref) {
  return GetAppointmentByIdUseCase(ref.read(appointmentRepositoryProvider));
});

final addAppointmentUseCaseProvider = Provider<AddAppointmentUseCase>((ref) {
  return AddAppointmentUseCase(ref.read(appointmentRepositoryProvider));
});

final updateAppointmentUseCaseProvider = Provider<UpdateAppointmentUseCase>((ref) {
  return UpdateAppointmentUseCase(ref.read(appointmentRepositoryProvider));
});

final updateAppointmentStatusUseCaseProvider =
    Provider<UpdateAppointmentStatusUseCase>((ref) {
  return UpdateAppointmentStatusUseCase(ref.read(appointmentRepositoryProvider));
});

final deleteAppointmentUseCaseProvider = Provider<DeleteAppointmentUseCase>((ref) {
  return DeleteAppointmentUseCase(ref.read(appointmentRepositoryProvider));
});

final getAllPatientsDataFormUseCaseProvider =
    Provider<GetAllPatientsDataFormUseCase>((ref) {
  return GetAllPatientsDataFormUseCase(ref.read(patientRepositoryProvider));
});

final patientsDataFormProvider = FutureProvider((ref) async {
  final getAllPatientsDataFormUseCase =
      ref.read(getAllPatientsDataFormUseCaseProvider);
  return await getAllPatientsDataFormUseCase();
});

final appointmentsViewModelProvider =
    StateNotifierProvider<AppointmentViewModel, List<Appointment>>((ref) {
  return AppointmentViewModel(
    ref.read(getAllAppointmentsUseCaseProvider),
    ref.read(getAppointmentByIdUseCaseProvider),
    ref.read(addAppointmentUseCaseProvider),
    ref.read(updateAppointmentUseCaseProvider),
    ref.read(updateAppointmentStatusUseCaseProvider),
    ref.read(deleteAppointmentUseCaseProvider),
    ref.read(getAllPatientsDataFormUseCaseProvider),
  );
});

final appointmentStatusFilterProvider = StateProvider<String?>((ref) => null);
final appointmentSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final appointments = ref.watch(appointmentsViewModelProvider);
  final statusFilter = ref.watch(appointmentStatusFilterProvider);
  final query = ref.watch(appointmentSearchQueryProvider).toLowerCase().trim();

  return appointments.where((a) {
    if (statusFilter != null && a.statusEnum.code != statusFilter) return false;
    if (query.isEmpty) return true;
    return a.patientName.toLowerCase().contains(query) ||
        a.dni.toLowerCase().contains(query) ||
        a.reason.toLowerCase().contains(query) ||
        a.treatmentName.toLowerCase().contains(query);
  }).toList();
});
