import 'package:dentify_flutter/payment/data/model/invoice_payment_response.dart';
import 'package:dentify_flutter/payment/data/model/invoice_response.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_status.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

Map<String, dynamic> _baseInvoice() => {
      'id': 12,
      'appointmentId': 101,
      'patientName': 'Ana Torres',
      'dni': '44556677',
      'email': 'ana@example.com',
      'totalAmount': 950.0,
      'paymentMethodId': 1,
      'paymentMethodName': 'Efectivo',
      'createdAt': '2026-11-19T14:30:00',
    };

void main() {
  group('InvoiceResponse balance fields', () {
    test('reads paid, pending, status, legacy, count and methods', () {
      final invoice = InvoiceResponse.fromJson({
        ..._baseInvoice(),
        'paidAmount': 350,
        'pendingBalance': 600.0,
        'status': 'PARTIAL',
        'legacy': false,
        'paymentsCount': 2,
        'paymentMethods': ['Efectivo', 'Transferencia'],
      }).toDomain();

      expect(invoice.totalAmount, Money.parse('950.00'));
      expect(invoice.paidAmount, Money.parse('350.00'));
      expect(invoice.pendingBalance, Money.parse('600.00'));
      expect(invoice.status, InvoiceStatus.partial);
      expect(invoice.status.label, 'Parcial');
      expect(invoice.legacy, isFalse);
      expect(invoice.paymentsCount, 2);
      expect(invoice.paymentMethods, ['Efectivo', 'Transferencia']);
      expect(invoice.hasPendingBalance, isTrue);
    });

    test('keeps cents from 2-decimal BigDecimal values', () {
      final invoice = InvoiceResponse.fromJson({
        ..._baseInvoice(),
        'totalAmount': 120.5,
        'paidAmount': 70.25,
        'pendingBalance': 50.25,
        'status': 'PARTIAL',
      }).toDomain();

      expect(invoice.paidAmount.cents, 7025);
      expect(invoice.pendingBalance.cents, 5025);
    });

    test('missing balance fields default to a fully paid invoice', () {
      final invoice = InvoiceResponse.fromJson(_baseInvoice()).toDomain();

      expect(invoice.paidAmount, Money.parse('950'));
      expect(invoice.pendingBalance, Money.zero);
      expect(invoice.status, InvoiceStatus.paid);
      expect(invoice.legacy, isFalse);
      expect(invoice.paymentsCount, 0);
      expect(invoice.paymentMethods, isEmpty);
      expect(invoice.hasPendingBalance, isFalse);
    });

    test('derives the status from the amounts when it is missing or unknown',
        () {
      InvoiceStatus statusFor(Map<String, dynamic> extra) =>
          InvoiceResponse.fromJson({..._baseInvoice(), ...extra})
              .toDomain()
              .status;

      expect(
        statusFor({'paidAmount': 0, 'pendingBalance': 950}),
        InvoiceStatus.pending,
      );
      expect(
        statusFor({'paidAmount': 350, 'pendingBalance': 600}),
        InvoiceStatus.partial,
      );
      expect(
        statusFor({'paidAmount': 950, 'pendingBalance': 0}),
        InvoiceStatus.paid,
      );
      expect(
        statusFor({'pendingBalance': 0, 'status': 'CANCELLED'}),
        InvoiceStatus.paid,
      );
      expect(
        statusFor({'paidAmount': 0, 'pendingBalance': 950, 'status': null}),
        InvoiceStatus.pending,
      );
      expect(statusFor({'status': 'pending'}), InvoiceStatus.pending);
    });

    test('a legacy invoice counts as paid and has no payments', () {
      final invoice = InvoiceResponse.fromJson({
        ..._baseInvoice(),
        'paidAmount': 950,
        'pendingBalance': 0,
        'status': 'PAID',
        'legacy': true,
        'paymentsCount': 0,
        'paymentMethods': [],
      }).toDomain();

      expect(invoice.legacy, isTrue);
      expect(invoice.status, InvoiceStatus.paid);
      expect(invoice.status.label, 'Pagado');
      expect(invoice.paymentsCount, 0);

      final withoutStatus = InvoiceResponse.fromJson({
        ..._baseInvoice(),
        'legacy': 'true',
      }).toDomain();
      expect(withoutStatus.legacy, isTrue);
      expect(withoutStatus.status, InvoiceStatus.paid);
    });

    test('ignores malformed method entries and duplicates', () {
      final invoice = InvoiceResponse.fromJson({
        ..._baseInvoice(),
        'paymentMethods': ['Efectivo', null, 3, ' ', 'Efectivo', 'Yape'],
        'paymentsCount': 'x',
        'legacy': 'quizás',
      }).toDomain();

      expect(invoice.paymentMethods, ['Efectivo', 'Yape']);
      expect(invoice.paymentsCount, 0);
      expect(invoice.legacy, isFalse);
    });
  });

  group('InvoicePaymentResponse', () {
    test('parses amount, method, notes and the UTC paidAt', () {
      final payment = InvoicePaymentResponse.fromJson({
        'id': 5,
        'amount': 350,
        'paymentMethodId': 1,
        'paymentMethodName': 'Efectivo',
        'notes': 'Primer abono',
        'paidAt': '2026-11-30T04:30:00Z',
      }).toDomain();

      expect(payment.id, 5);
      expect(payment.amount.cents, 35000);
      expect(payment.paymentMethodId, 1);
      expect(payment.paymentMethodName, 'Efectivo');
      expect(payment.notes, 'Primer abono');
      expect(payment.paidAt.isUtc, isTrue);
      expect(payment.paidAt, DateTime.utc(2026, 11, 30, 4, 30));
      expect(
        payment.paidAt.toLocal(),
        DateTime.utc(2026, 11, 30, 4, 30).toLocal(),
      );
      expect(payment.paidAt.toLocal().isUtc, isFalse);
      expect(
        DateFormat('dd/MM/yyyy · hh:mm a').format(payment.paidAt.toLocal()),
        DateFormat('dd/MM/yyyy · hh:mm a')
            .format(DateTime.utc(2026, 11, 30, 4, 30).toLocal()),
      );
    });

    test('tolerates null notes, decimals and a missing method name', () {
      final payment = InvoicePaymentResponse.fromJson({
        'id': 6,
        'amount': 600.5,
        'paymentMethodId': 2,
        'notes': null,
        'paidAt': '2026-12-01T15:00:00Z',
      }).toDomain();

      expect(payment.amount.cents, 60050);
      expect(payment.notes, isNull);
      expect(payment.paymentMethodName, 'Método #2');
    });
  });
}
