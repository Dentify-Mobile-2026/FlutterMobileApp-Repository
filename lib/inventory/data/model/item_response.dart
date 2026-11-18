import 'package:dentify_flutter/inventory/domain/model/item.dart';

class ItemResponse {
  final int id;
  final String name;
  final double price;
  final int stockQuantity;
  final bool isActive;
  final String category;

  ItemResponse(
    {
      required this.id,
      required this.name,
      required this.price,
      required this.stockQuantity,
      required this.isActive,
      required this.category
    }
  );

  factory ItemResponse.fromJson(Map<String, dynamic> json) {
    return ItemResponse(
      id: json['id'], 
      name: json['name'], 
      price: json['price'], 
      stockQuantity: json['stockQuantity'], 
      isActive: json['isActive'], 
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stockQuantity': stockQuantity,
      'isActive': isActive,
      'category': category,
    };
  }

  Item toDomain() {
    return Item(
      id: id, 
      name: name, 
      price: price, 
      stockQuantity: stockQuantity, 
      isActive: isActive, 
      category: category
    );
  }
}