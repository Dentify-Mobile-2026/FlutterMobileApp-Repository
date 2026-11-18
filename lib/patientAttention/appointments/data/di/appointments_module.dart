import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/navigation/dentify_app.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/services/appointment_service.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/repository/appointment_repository_impl.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/repository/patient_repository_impl.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/patient_repository.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/add_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/delete_appointment_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_all_appointments_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_all_patients_data_form_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/get_appointment_by_id_use_case.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/usecases/update_appointment_use_case.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AppointmentsModule {
  static AppointmentService provideAppointmentService() {
    return AppointmentService(ApiConstants.baseUrl); // Replace with your actual base URL
  }

  static AppointmentRepository provideAppointmentRepository() {
    return AppointmentRepositoryImpl(provideAppointmentService());
  }

  static PatientRepository providePatientRepository() {
    return PatientRepositoryImpl(provideAppointmentService());
  }

  static GetAllAppointmentsUseCase provideGetAllAppointmentsUseCase() {
    return GetAllAppointmentsUseCase(provideAppointmentRepository());
  }

  static GetAppointmentByIdUseCase provideGetAppointmentByIdUseCase() {
    return GetAppointmentByIdUseCase(provideAppointmentRepository());
  }

  static GetAllPatientsDataFormUseCase provideGetAllPatientsDataFormUseCase() {
    return GetAllPatientsDataFormUseCase(providePatientRepository());
  }

  static AddAppointmentUseCase provideAddAppointmentUseCase() {
    return AddAppointmentUseCase(provideAppointmentRepository());
  }

  static UpdateAppointmentUseCase provideUpdateAppointmentUseCase() {
    return UpdateAppointmentUseCase(provideAppointmentRepository());
  }

  static DeleteAppointmentUseCase provideDeleteAppointmentUseCase() {
    return DeleteAppointmentUseCase(provideAppointmentRepository());
  }

  static Widget provideAppointmentModule(){
    return MultiProvider(
      providers: [
        Provider<AppointmentService>(create: (_) => provideAppointmentService()),
        Provider<AppointmentRepository>(create: (_) => provideAppointmentRepository()),
        Provider<PatientRepository>(create: (_) => providePatientRepository()),
        Provider<GetAllAppointmentsUseCase>(create: (_) => provideGetAllAppointmentsUseCase()),
        Provider<GetAppointmentByIdUseCase>(create: (_) => provideGetAppointmentByIdUseCase()),
        Provider<GetAllPatientsDataFormUseCase>(create: (_) => provideGetAllPatientsDataFormUseCase()),
        Provider<AddAppointmentUseCase>(create: (_) => provideAddAppointmentUseCase()),
        Provider<UpdateAppointmentUseCase>(create: (_) => provideUpdateAppointmentUseCase()),
        Provider<DeleteAppointmentUseCase>(create: (_) => provideDeleteAppointmentUseCase()),
      ],
      child: const DentifyApp(),
    );
  }
}