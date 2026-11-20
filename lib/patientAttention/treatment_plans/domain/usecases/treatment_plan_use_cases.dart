import '../model/treatment_plan.dart';
import '../repositories/treatment_plan_repository.dart';

class TreatmentPlanUseCases {
  final TreatmentPlanRepository repository;
  const TreatmentPlanUseCases(this.repository);
  Future<List<TreatmentPlan>> load(int patientId) =>
      repository.getPlans(patientId);
  Future<TreatmentPlan> create(int patientId, TreatmentPlanDraft draft) =>
      repository.create(patientId, draft);
  Future<TreatmentPlan> changeStatus(
          int patientId, int planId, String status) =>
      repository.updateStatus(patientId, planId, status);
  Future<TreatmentPlan> changeItemStatus(
          int planId, int itemId, String status) =>
      repository.updateItemStatus(planId, itemId, status);
}
