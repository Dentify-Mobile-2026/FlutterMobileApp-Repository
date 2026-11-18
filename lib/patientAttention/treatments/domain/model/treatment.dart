import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment_category.dart';

class Treatment {
  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int estimatedDurationMinutes;
  final bool isActive;

  const Treatment({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.estimatedDurationMinutes,
    required this.isActive,
  });

  TreatmentCategory get categoryEnum => TreatmentCategory.fromCode(category);
}
