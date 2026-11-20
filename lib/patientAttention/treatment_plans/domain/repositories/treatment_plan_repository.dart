import '../model/treatment_plan.dart';

abstract class TreatmentPlanRepository {
  Future<List<TreatmentPlan>> getPlans(int patientId);
  Future<TreatmentPlan> create(int patientId, TreatmentPlanDraft draft);
  Future<TreatmentPlan> updateStatus(int patientId, int planId, String status);
  Future<TreatmentPlan> updateItemStatus(int planId, int itemId, String status);
}
