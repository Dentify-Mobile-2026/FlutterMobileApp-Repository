import '../../domain/model/plan_amount.dart';
import '../../domain/model/treatment_plan.dart';

class TreatmentPlanDto {
  static TreatmentPlan fromJson(Map<String, dynamic> json) => TreatmentPlan(
        id: json['id'] as int,
        title: json['title'] as String,
        notes: json['notes'] as String? ?? '',
        status: json['status'] as String,
        totalAmount: PlanAmount.fromJson(json['totalAmount']),
        completedItems: json['completedItems'] as int,
        totalItems: json['totalItems'] as int,
        items: (json['items'] as List)
            .map((dynamic item) => TreatmentPlanItem(
                  id: item['id'] as int,
                  treatmentId: item['treatmentId'] as int,
                  treatmentName: item['treatmentName'] as String,
                  itemStatus: item['itemStatus'] as String,
                  toothNumber: item['toothNumber'] as String?,
                  agreedPrice: PlanAmount.fromJson(item['agreedPrice']),
                ))
            .toList(growable: false),
      );

  static Map<String, dynamic> toJson(TreatmentPlanDraft draft) => {
        'title': draft.title,
        'notes': draft.notes,
        'items': draft.items
            .map((item) => {
                  'treatmentId': item.treatmentId,
                  'toothNumber': item.toothNumber,
                  // A decimal string is deserialized to BigDecimal without binary rounding.
                  'agreedPrice': item.agreedPrice.decimal,
                })
            .toList(),
      };
}
