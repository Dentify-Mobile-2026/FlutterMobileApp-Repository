import 'package:dentify_flutter/payment/data/model/payment_method_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentMethodResponse', () {
    test('maps id, name and description from the API', () {
      final method = PaymentMethodResponse.fromJson({
        'id': 2,
        'name': 'Tarjeta de Credito',
        'description': 'Visa o Mastercard',
      }).toDomain();

      expect(method.id, 2);
      expect(method.name, 'Tarjeta de Credito');
      expect(method.description, 'Visa o Mastercard');
    });

    test('tolerates missing or mistyped fields', () {
      final method = PaymentMethodResponse.fromJson({
        'id': '7',
        'name': null,
      }).toDomain();

      expect(method.id, 7);
      expect(method.name, 'Método #7');
      expect(method.description, '');
    });
  });
}
