import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/remote/services/treatment_service.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/repository/treatment_repository_impl.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/repositories/treatment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final treatmentServiceProvider = Provider<TreatmentService>((ref) {
  return TreatmentService(ApiConstants.baseUrl);
});

final treatmentRepositoryProvider = Provider<TreatmentRepository>((ref) {
  return TreatmentRepositoryImpl(ref.read(treatmentServiceProvider));
});
