import 'plan_amount.dart';

class TreatmentPlan {
  final int id;
  final String title, notes, status;
  final PlanAmount totalAmount;
  final int completedItems, totalItems;
  final List<TreatmentPlanItem> items;

  const TreatmentPlan(
      {required this.id,
      required this.title,
      required this.notes,
      required this.status,
      required this.totalAmount,
      required this.completedItems,
      required this.totalItems,
      required this.items});

  double get progress => totalItems == 0 ? 0 : completedItems / totalItems;
  bool get canUpdateItems =>
      status == 'APPROVED' || status == 'IN_PROGRESS' || status == 'COMPLETED';
  String get statusLabel =>
      const {
        'DRAFT': 'Borrador',
        'APPROVED': 'Aprobado',
        'IN_PROGRESS': 'En curso',
        'COMPLETED': 'Completado',
        'CANCELLED': 'Cancelado'
      }[status] ??
      status;
}

class TreatmentPlanItem {
  final int id, treatmentId;
  final String treatmentName, itemStatus;
  final String? toothNumber;
  final PlanAmount agreedPrice;

  const TreatmentPlanItem(
      {required this.id,
      required this.treatmentId,
      required this.treatmentName,
      required this.itemStatus,
      this.toothNumber,
      required this.agreedPrice});
}

class PlanItemDraft {
  final int treatmentId;
  final String? toothNumber;
  final PlanAmount agreedPrice;
  const PlanItemDraft(
      {required this.treatmentId, this.toothNumber, required this.agreedPrice});
}

class TreatmentPlanDraft {
  final String title, notes;
  final List<PlanItemDraft> items;
  const TreatmentPlanDraft(
      {required this.title, required this.notes, required this.items});
  PlanAmount get total =>
      PlanAmount(items.fold(0, (sum, item) => sum + item.agreedPrice.cents));
}
