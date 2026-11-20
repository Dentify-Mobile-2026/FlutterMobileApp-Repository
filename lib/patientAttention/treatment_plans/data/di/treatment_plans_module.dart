import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/treatment_plan_repository.dart';
import '../../domain/usecases/treatment_plan_use_cases.dart';
import '../repository/treatment_plan_repository_impl.dart';
import '../services/treatment_plan_service.dart';

final treatmentPlanRepositoryProvider =
    Provider.autoDispose<TreatmentPlanRepository>((ref) {
  final service = TreatmentPlanService(ApiConstants.baseUrl);
  ref.onDispose(service.close);
  return TreatmentPlanRepositoryImpl(service);
});

final treatmentPlanUseCasesProvider =
    Provider.autoDispose<TreatmentPlanUseCases>((ref) =>
        TreatmentPlanUseCases(ref.watch(treatmentPlanRepositoryProvider)));
