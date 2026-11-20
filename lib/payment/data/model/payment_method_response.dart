import 'package:dentify_flutter/payment/data/model/json_readers.dart';
import 'package:dentify_flutter/payment/domain/model/payment_method.dart';

class PaymentMethodResponse {
  final int id;
  final String name;
  final String description;

  const PaymentMethodResponse({
    required this.id,
    required this.name,
    this.description = '',
  });

  factory PaymentMethodResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodResponse(
      id: readInt(json['id']) ?? 0,
      name: readString(json['name']) ?? '',
      description: readString(json['description']) ?? '',
    );
  }

  PaymentMethod toDomain() {
    return PaymentMethod(
      id: id,
      name: name.isNotEmpty ? name : 'Método #$id',
      description: description,
    );
  }
}
