import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/di/treatment_plans_module.dart';
import '../../domain/model/treatment_plan.dart';
import '../../domain/usecases/treatment_plan_use_cases.dart';

final treatmentPlansProvider = StateNotifierProvider.autoDispose
    .family<TreatmentPlansViewModel, AsyncValue<List<TreatmentPlan>>, int>(
        (ref, patientId) => TreatmentPlansViewModel(
            ref.watch(treatmentPlanUseCasesProvider), patientId));

class TreatmentPlansViewModel
    extends StateNotifier<AsyncValue<List<TreatmentPlan>>> {
  final TreatmentPlanUseCases useCases;
  final int patientId;
  TreatmentPlansViewModel(this.useCases, this.patientId)
      : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => useCases.load(patientId));
    if (mounted) state = result;
  }

  void _replace(TreatmentPlan plan) {
    if (!mounted) return;
    final previous = state.valueOrNull ?? <TreatmentPlan>[];
    state = AsyncData([plan, ...previous.where((item) => item.id != plan.id)]);
  }

  Future<void> create(TreatmentPlanDraft draft) async =>
      _replace(await useCases.create(patientId, draft));
  Future<void> changeStatus(int planId, String status) async =>
      _replace(await useCases.changeStatus(patientId, planId, status));
  Future<void> changeItemStatus(int planId, int itemId, String status) async =>
      _replace(await useCases.changeItemStatus(planId, itemId, status));
}
