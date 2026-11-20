import 'dart:convert';

import 'package:dentify_flutter/payment/data/remote/dto/create_invoice_request.dart';
import 'package:dentify_flutter/payment/data/remote/dto/register_payment_request.dart';
import 'package:dentify_flutter/payment/data/remote/services/invoice_service.dart';
import 'package:dentify_flutter/payment/data/repository/invoice_repository_impl.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_status.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/domain/model/register_payment.dart';
import 'package:dentify_flutter/payment/domain/usecases/get_invoice_payments_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _baseUrl = 'https://example.com/api/';
const _requestId = '3f2b8c1e-9a4d-4e7f-b1c2-5d6e7f8a9b0c';

http.Response _jsonResponse(Object body, int status) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json'},
  );
}

Map<String, dynamic> _invoiceJson({
  required num paid,
  required num pending,
  required String status,
  List<String> methods = const ['Efectivo'],
}) {
  return {
    'id': 12,
    'appointmentId': 101,
    'patientName': 'Ana Torres',
    'dni': '44556677',
    'email': 'ana@example.com',
    'totalAmount': 950.0,
    'paidAmount': paid,
    'pendingBalance': pending,
    'status': status,
    'legacy': false,
    'paymentsCount': methods.length,
    'paymentMethods': methods,
  };
}

RegisterPaymentRequest _registerRequest({String? notes}) {
  return RegisterPaymentRequest.fromDomain(RegisterPayment(
    amount: Money.parse('600'),
    paymentMethodId: 7,
    notes: notes,
    requestId: _requestId,
  ));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'access_token': 'token-123'});
  });

  group('POST v1/invoices with initialPayment', () {
    Future<String?> captureCreateBody(CreateInvoiceRequest request) async {
      http.Request? captured;
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((r) async {
          captured = r;
          return http.Response('', 201);
        }),
      );
      await service.createInvoice(request);
      return captured?.body;
    }

    test('sends the initial payment as a decimal string with the method',
        () async {
      final body = await captureCreateBody(CreateInvoiceRequest.fromDomain(
        NewInvoice(
          appointmentId: 101,
          amount: Money.parse('950'),
          paymentMethodId: 7,
          initialPayment: Money.parse('350'),
        ),
      ));

      expect(
        body,
        '{"appointmentId":101,"amount":"950.00","paymentMethodId":7,'
        '"initialPayment":"350.00"}',
      );
    });

    test('a zero initial payment sends "0.00" and a null method', () async {
      final body = await captureCreateBody(CreateInvoiceRequest.fromDomain(
        NewInvoice(
          appointmentId: 101,
          amount: Money.parse('950'),
          paymentMethodId: null,
          initialPayment: Money.zero,
        ),
      ));

      expect(
        body,
        '{"appointmentId":101,"amount":"950.00","paymentMethodId":null,'
        '"initialPayment":"0.00"}',
      );
    });

    test('a zero initial payment drops a method id even if one is given', () {
      final json = CreateInvoiceRequest(
        appointmentId: 101,
        amount: Money.parse('950'),
        paymentMethodId: 7,
        initialPayment: Money.zero,
      ).toJson();

      expect(json['paymentMethodId'], isNull);
      expect(json['initialPayment'], '0.00');
    });
  });

  group('POST v1/invoices/{id}/payments', () {
    test('posts amount, method, notes and requestId with the bearer token',
        () async {
      http.Request? captured;
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((request) async {
          captured = request;
          return _jsonResponse(
            _invoiceJson(paid: 950, pending: 0, status: 'PAID'),
            201,
          );
        }),
      );

      await service.registerPayment(12, _registerRequest());

      expect(captured?.method, 'POST');
      expect(captured?.url, Uri.parse('${_baseUrl}v1/invoices/12/payments'));
      expect(captured?.headers['Authorization'], 'Bearer token-123');
      expect(
        captured?.body,
        '{"amount":"600.00","paymentMethodId":7,"notes":null,'
        '"requestId":"$_requestId"}',
      );
    });

    test('trims notes and sends empty notes as null', () {
      expect(_registerRequest(notes: '  Segundo abono ').toJson()['notes'],
          'Segundo abono');
      expect(_registerRequest(notes: '   ').toJson()['notes'], isNull);
    });

    for (final status in [201, 200]) {
      test('HTTP $status returns the updated invoice', () async {
        final service = InvoiceService(
          _baseUrl,
          client: MockClient((_) async => _jsonResponse(
                _invoiceJson(
                  paid: 950,
                  pending: 0,
                  status: 'PAID',
                  methods: ['Efectivo', 'Transferencia'],
                ),
                status,
              )),
        );

        final invoice =
            (await service.registerPayment(12, _registerRequest())).toDomain();

        expect(invoice.status, InvoiceStatus.paid);
        expect(invoice.paidAmount, Money.parse('950'));
        expect(invoice.pendingBalance, Money.zero);
        expect(invoice.paymentMethods, ['Efectivo', 'Transferencia']);
      });
    }

    test('a 409 carries the server message (overpayment)', () async {
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((_) async => _jsonResponse({
              'error':
                  'El abono (S/. 600.00) excede el saldo pendiente (S/. 200.00)',
            }, 409)),
      );

      await expectLater(
        service.registerPayment(12, _registerRequest()),
        throwsA(isA<PaymentApiException>()
            .having((e) => e.statusCode, 'statusCode', 409)
            .having((e) => e.message, 'message',
                'El abono (S/. 600.00) excede el saldo pendiente (S/. 200.00)')),
      );
    });

    test('a 409 without message uses a payment-specific fallback', () async {
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((_) async => http.Response('', 409)),
      );

      await expectLater(
        service.registerPayment(12, _registerRequest()),
        throwsA(isA<PaymentApiException>().having(
          (e) => e.message,
          'message',
          contains('saldo del comprobante cambió'),
        )),
      );
    });

    test('a 400 surfaces the server validation message', () async {
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((_) async =>
            _jsonResponse({'error': 'El monto debe ser mayor a 0'}, 400)),
      );

      await expectLater(
        service.registerPayment(12, _registerRequest()),
        throwsA(isA<PaymentApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.message, 'message', 'El monto debe ser mayor a 0')),
      );
    });
  });

  group('GET v1/invoices/{id}/payments', () {
    test('parses the payments of the invoice', () async {
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url, Uri.parse('${_baseUrl}v1/invoices/12/payments'));
          return _jsonResponse([
            {
              'id': 1,
              'amount': 350.0,
              'paymentMethodId': 7,
              'paymentMethodName': 'Efectivo',
              'notes': null,
              'paidAt': '2026-11-28T14:00:00Z',
            },
          ], 200);
        }),
      );

      final payments = await service.getInvoicePayments(12);

      expect(payments.single.amount.cents, 35000);
      expect(payments.single.toDomain().paidAt,
          DateTime.utc(2026, 11, 28, 14));
    });

    test('a 404 means the invoice does not exist and throws', () async {
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((_) async => http.Response('', 404)),
      );

      await expectLater(
        service.getInvoicePayments(99),
        throwsA(isA<PaymentApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.message, 'message', 'El comprobante no existe.')),
      );
    });

    test('the use case returns the payments oldest first', () async {
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((_) async => _jsonResponse([
              {
                'id': 3,
                'amount': 100,
                'paymentMethodId': 7,
                'paidAt': '2026-12-02T10:00:00Z',
              },
              {
                'id': 1,
                'amount': 200,
                'paymentMethodId': 7,
                'paidAt': '2026-11-28T14:00:00Z',
              },
              {
                'id': 2,
                'amount': 300,
                'paymentMethodId': 9,
                'paidAt': '2026-11-28T14:00:00Z',
              },
            ], 200)),
      );
      final useCase =
          GetInvoicePaymentsUseCase(InvoiceRepositoryImpl(service));

      final payments = await useCase(12);

      expect(payments.map((p) => p.id), [1, 2, 3]);
    });
  });
}
