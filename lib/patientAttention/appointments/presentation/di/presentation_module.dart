import 'package:dentify_flutter/patientAttention/appointments/data/di/dependency_injection.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/add_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/delete_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_all_appointments_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_all_patients_data_form_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_appointment_by_id_use_case.dart';
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

final deleteAppointmentUseCaseProvider = Provider<DeleteAppointmentUseCase>((ref) {
  return DeleteAppointmentUseCase(ref.read(appointmentRepositoryProvider));
});

final getAllPatientsDataFormUseCaseProvider = Provider<GetAllPatientsDataFormUseCase>((ref) {
  return GetAllPatientsDataFormUseCase(ref.read(patientRepositoryProvider));
});

//estado para obtener todos los pacientes
final patientsDataFormProvider = FutureProvider((ref) async {
  final getAllPatientsDataFormUseCase = ref.read(getAllPatientsDataFormUseCaseProvider);
  return await getAllPatientsDataFormUseCase();
});

final appointmentsViewModelProvider = StateNotifierProvider<AppointmentViewModel, List<Appointment>>((ref) {
  return AppointmentViewModel(
    ref.read(getAllAppointmentsUseCaseProvider),
    ref.read(getAppointmentByIdUseCaseProvider),
    ref.read(addAppointmentUseCaseProvider),
    ref.read(updateAppointmentUseCaseProvider),
    ref.read(deleteAppointmentUseCaseProvider),
    ref.read(getAllPatientsDataFormUseCaseProvider),
    );
});