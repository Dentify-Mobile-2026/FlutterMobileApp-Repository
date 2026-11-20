import 'dart:convert';

import 'package:dentify_flutter/payment/data/remote/dto/create_invoice_request.dart';
import 'package:dentify_flutter/payment/data/remote/services/invoice_service.dart';
import 'package:dentify_flutter/payment/data/remote/services/payment_method_service.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _baseUrl = 'https://example.com/api/';

http.Response _jsonResponse(Object body, int status) {
  // Sin charset en la cabecera, como suele responder el backend.
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'access_token': 'token-123'});
  });

  group('InvoiceService.createInvoice', () {
    test('posts the amount as a decimal string with the bearer token',
        () async {
      http.Request? captured;
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((request) async {
          captured = request;
          return http.Response('', 201);
        }),
      );

      await service.createInvoice(CreateInvoiceRequest(
        appointmentId: 101,
        amount: Money.parse('120,5'),
        paymentMethodId: 9,
      ));

      expect(captured?.method, 'POST');
      expect(captured?.url, Uri.parse('${_baseUrl}v1/invoices'));
      expect(captured?.headers['Authorization'], 'Bearer token-123');
      expect(
        captured?.body,
        '{"appointmentId":101,"amount":"120.50","paymentMethodId":9}',
      );
    });

    test('throws PaymentApiException with the server error message', () async {
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((_) async => _jsonResponse(
              {'error': 'La cita ya tiene un comprobante'},
              409,
            )),
      );

      await expectLater(
        service.createInvoice(CreateInvoiceRequest(
          appointmentId: 101,
          amount: Money.parse('80'),
          paymentMethodId: 7,
        )),
        throwsA(isA<PaymentApiException>()
            .having((e) => e.statusCode, 'statusCode', 409)
            .having((e) => e.isConflict, 'isConflict', isTrue)
            .having((e) => e.message, 'message',
                'La cita ya tiene un comprobante')),
      );
    });

    test('falls back to a Spanish message when the body has no error field',
        () async {
      final service = InvoiceService(
        _baseUrl,
        client: MockClient(
            (_) async => http.Response('<html>Bad Gateway</html>', 502)),
      );

      await expectLater(
        service.createInvoice(CreateInvoiceRequest(
          appointmentId: 1,
          amount: Money.parse('10'),
          paymentMethodId: 7,
        )),
        throwsA(isA<PaymentApiException>()
            .having((e) => e.statusCode, 'statusCode', 502)
            .having((e) => e.message, 'message',
                'Error del servidor. Intente nuevamente en unos minutos.')),
      );
    });
  });

  group('GET endpoints', () {
    test('getAllInvoices decodes UTF-8 bodies without charset', () async {
      final service = InvoiceService(
        _baseUrl,
        client: MockClient((request) async {
          expect(request.url, Uri.parse('${_baseUrl}v1/invoices'));
          return _jsonResponse([
            {
              'id': 1,
              'appointmentId': 101,
              'patientName': 'José Núñez',
              'totalAmount': 120.5,
              'paymentMethodName': 'Tarjeta de Crédito',
            },
          ], 200);
        }),
      );

      final invoices = await service.getAllInvoices();

      expect(invoices.single.patientName, 'José Núñez');
      expect(invoices.single.paymentMethodName, 'Tarjeta de Crédito');
      expect(invoices.single.totalAmount.cents, 12050);
    });

    test('getAllPaymentMethods reads v1/payment-methods', () async {
      final service = PaymentMethodService(
        _baseUrl,
        client: MockClient((request) async {
          expect(request.url, Uri.parse('${_baseUrl}v1/payment-methods'));
          expect(request.headers['Authorization'], 'Bearer token-123');
          return _jsonResponse([
            {'id': 1, 'name': 'Efectivo', 'description': 'Pago en caja'},
            {'id': 2, 'name': 'Tarjeta de Credito', 'description': ''},
          ], 200);
        }),
      );

      final methods = await service.getAllPaymentMethods();

      expect(methods.map((m) => m.id), [1, 2]);
      expect(methods.first.name, 'Efectivo');
    });

    test('a 401 surfaces as PaymentApiException', () async {
      final service = PaymentMethodService(
        _baseUrl,
        client: MockClient((_) async => http.Response('', 401)),
      );

      await expectLater(
        service.getAllPaymentMethods(),
        throwsA(isA<PaymentApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });
}
