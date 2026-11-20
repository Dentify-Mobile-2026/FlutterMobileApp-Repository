import '../../domain/model/treatment_plan.dart';
import '../../domain/repositories/treatment_plan_repository.dart';
import '../dto/treatment_plan_dto.dart';
import '../services/treatment_plan_service.dart';

class TreatmentPlanRepositoryImpl implements TreatmentPlanRepository {
  final TreatmentPlanService service;
  const TreatmentPlanRepositoryImpl(this.service);

  @override
  Future<List<TreatmentPlan>> getPlans(int patientId) async =>
      (await service.request('GET', 'patients/$patientId/treatment-plans')
              as List)
          .map((dynamic json) =>
              TreatmentPlanDto.fromJson(json as Map<String, dynamic>))
          .toList();

  @override
  Future<TreatmentPlan> create(int patientId, TreatmentPlanDraft draft) async =>
      TreatmentPlanDto.fromJson(await service.request(
          'POST',
          'patients/$patientId/treatment-plans',
          TreatmentPlanDto.toJson(draft)) as Map<String, dynamic>);

  @override
  Future<TreatmentPlan> updateStatus(
          int patientId, int planId, String status) async =>
      TreatmentPlanDto.fromJson(await service.request(
          'PUT',
          'patients/$patientId/treatment-plans/$planId/status',
          {'status': status}) as Map<String, dynamic>);

  @override
  Future<TreatmentPlan> updateItemStatus(
          int planId, int itemId, String status) async =>
      TreatmentPlanDto.fromJson(await service.request(
          'PUT',
          'treatment-plans/$planId/items/$itemId/status',
          {'status': status}) as Map<String, dynamic>);
}
