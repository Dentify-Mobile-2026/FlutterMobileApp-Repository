import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';

class TreatmentResponse {
  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int estimatedDurationMinutes;
  final bool isActive;

  const TreatmentResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.estimatedDurationMinutes,
    required this.isActive,
  });

  factory TreatmentResponse.fromJson(Map<String, dynamic> json) {
    return TreatmentResponse(
      id: json['id'],
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'PREVENTION').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 30,
      isActive: json['isActive'] ?? true,
    );
  }

  Treatment toDomain() {
    return Treatment(
      id: id,
      name: name,
      description: description,
      category: category,
      price: price,
      estimatedDurationMinutes: estimatedDurationMinutes,
      isActive: isActive,
    );
  }
}
