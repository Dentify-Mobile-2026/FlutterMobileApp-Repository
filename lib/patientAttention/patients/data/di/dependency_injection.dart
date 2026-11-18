import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/services/medical_history_service.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/services/patient_service.dart';
import 'package:dentify_flutter/patientAttention/patients/data/repository/medical_history_repository_impl.dart';
import 'package:dentify_flutter/patientAttention/patients/data/repository/patient_repository_impl.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/repository/medical_history_repository.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/repository/patient_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientServiceProvider = Provider<PatientService>(
  (ref) {
    return PatientService(ApiConstants.baseUrl);
  }
);

final patientRepositoryProvider = Provider<PatientRepository>(
  (ref) {
    return PatientRepositoryImpl(ref.read(patientServiceProvider));
  }
);

final medicalHistoryServiceProvider = Provider<MedicalHistoryService>(
  (ref) {
    return MedicalHistoryService(ApiConstants.baseUrl);
  }
);

final medicalHistoryRepositoryProvider = Provider<MedicalHistoryRepository>(
  (ref) {
    return MedicalHistoryRepositoryImpl(ref.read(medicalHistoryServiceProvider));
  }
);