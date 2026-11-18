import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/services/appointment_service.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/repository/appointment_repository_impl.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/repository/patient_repository_impl.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/patient_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//servicios y repositorios ligados

final appointmentServiceProvider = Provider<AppointmentService>(
  (ref) {
    return AppointmentService(ApiConstants.baseUrl);
  }
);

final appointmentRepositoryProvider = Provider<AppointmentRepository>(
  (ref) {
    return AppointmentRepositoryImpl(ref.read(appointmentServiceProvider));
  }
);

final patientRepositoryProvider = Provider<PatientRepository>(
  (ref) {
    return PatientRepositoryImpl(ref.read(appointmentServiceProvider));
  }
);