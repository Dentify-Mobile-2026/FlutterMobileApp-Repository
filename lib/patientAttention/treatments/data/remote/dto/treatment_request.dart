class TreatmentRequest {
  final String name;
  final String description;
  final String category;
  final double price;
  final int estimatedDurationMinutes;
  final bool isActive;

  const TreatmentRequest({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.estimatedDurationMinutes,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'isActive': isActive,
    };
  }
}
