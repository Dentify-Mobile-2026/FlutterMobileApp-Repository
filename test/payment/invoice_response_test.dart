import 'package:dentify_flutter/payment/data/model/invoice_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InvoiceResponse', () {
    test('keeps decimals: 120.5 becomes 12050 cents, not truncated', () {
      final invoice = InvoiceResponse.fromJson({
        'id': 1,
        'appointmentId': 101,
        'patientName': 'Ana Torres',
        'dni': '44556677',
        'email': 'ana@example.com',
        'totalAmount': 120.5,
        'paymentMethodId': 2,
        'paymentMethodName': 'Tarjeta de Credito',
        'createdAt': '2026-11-19T14:30:00',
      }).toDomain();

      expect(invoice.totalAmount.cents, 12050);
      expect(invoice.totalAmount.format(), 'S/. 120.50');
      expect(invoice.paymentMethodId, 2);
      expect(invoice.paymentMethodName, 'Tarjeta de Credito');
      expect(invoice.createdAt, DateTime(2026, 11, 19, 14, 30));
    });

    test('a missing paymentMethodName gives null', () {
      final invoice = InvoiceResponse.fromJson({
        'id': 2,
        'appointmentId': 102,
        'patientName': 'Bruno Díaz',
        'dni': '11223344',
        'email': '',
        'totalAmount': 80,
      }).toDomain();

      expect(invoice.paymentMethodName, isNull);
      expect(invoice.paymentMethodId, isNull);
      expect(invoice.createdAt, isNull);
    });

    test('falls back to amount when totalAmount is absent', () {
      final invoice = InvoiceResponse.fromJson({
        'id': 3,
        'appointmentId': 103,
        'patientName': 'Carla Ruiz',
        'dni': '99887766',
        'email': 'carla@example.com',
        'amount': 99.99,
      }).toDomain();

      expect(invoice.totalAmount.cents, 9999);
    });

    test('prefers totalAmount over amount and survives a malformed payload', () {
      expect(
        InvoiceResponse.fromJson({'totalAmount': 50.25, 'amount': 10})
            .totalAmount
            .cents,
        5025,
      );

      final invoice = InvoiceResponse.fromJson({
        'id': null,
        'appointmentId': '104',
        'totalAmount': null,
        'amount': null,
        'createdAt': 'no-es-fecha',
      }).toDomain();

      expect(invoice.id, 0);
      expect(invoice.appointmentId, 104);
      expect(invoice.patientName, 'Paciente');
      expect(invoice.totalAmount.cents, 0);
      expect(invoice.createdAt, isNull);
    });
  });
}
