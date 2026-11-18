class ItemRequest {
  final String name;
  final double price;
  final int stockQuantity;
  final bool? isActive;
  final String category;

  ItemRequest({
    required this.name,
    required this.price,
    required this.stockQuantity,
    this.isActive,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'price': price,
      'stockQuantity': stockQuantity,
      'category': category,
    };
    if (isActive != null) {
      map['isActive'] = isActive!;
    }
    return map;
  }
}