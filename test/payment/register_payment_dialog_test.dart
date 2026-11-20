import 'dart:async';
import 'dart:convert';

import 'package:dentify_flutter/payment/data/remote/services/invoice_service.dart';
import 'package:dentify_flutter/payment/data/repository/invoice_repository_impl.dart';
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/domain/repository/invoice_repository.dart';
import 'package:dentify_flutter/payment/presentation/view/invoice_view.dart';
import 'package:dentify_flutter/payment/presentation/widgets/register_payment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'payment_test_support.dart';

Invoice _partialInvoice() => testInvoice(
      id: 4,
      patient: 'Ana Torres',
      total: '950',
      paid: '350',
      methods: ['Efectivo'],
      paymentsCount: 1,
    );

final _submit = find.byKey(RegisterPaymentDialog.submitButtonKey);
final _amount = find.byKey(RegisterPaymentDialog.amountFieldKey);
final _notes = find.byKey(RegisterPaymentDialog.notesFieldKey);

Future<void> _openDialog(
  WidgetTester tester,
  Size size,
  InvoiceRepository invoices,
) async {
  await pumpInvoiceView(tester, size, invoices: invoices);
  await tester.tap(find.byKey(InvoiceItemView.registerPaymentButtonKey(4)));
  await tester.pumpAndSettle();
  expect(find.byType(RegisterPaymentDialog), findsOneWidget);
}

Future<void> _selectMethod(WidgetTester tester, String name) async {
  final chip = find.descendant(
    of: find.byType(RegisterPaymentDialog),
    matching: find.widgetWithText(ChoiceChip, name),
  );
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pump();
}

Future<void> _tapSubmit(WidgetTester tester) async {
  await tester.ensureVisible(_submit);
  await tester.pump();
  await tester.tap(_submit);
}

Future<void> _enterAmount(WidgetTester tester, String text) async {
  await tester.ensureVisible(_amount);
  await tester.enterText(_amount, text);
  await tester.pump();
}

Map<String, dynamic> _invoiceJson({required bool paid}) => {
      'id': 4,
      'appointmentId': 104,
      'patientName': 'Ana Torres',
      'dni': '44554000',
      'email': '',
      'totalAmount': 950.0,
      'paidAmount': paid ? 950.0 : 350.0,
      'pendingBalance': paid ? 0 : 600.0,
      'status': paid ? 'PAID' : 'PARTIAL',
      'legacy': false,
      'paymentsCount': paid ? 2 : 1,
      'paymentMethods': paid ? ['Efectivo', 'Transferencia'] : ['Efectivo'],
    };

http.Response _json(Object body, int status) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json'},
    );

void main() {
  group('RegisterPaymentDialog.validateAmount', () {
    final pending = Money.parse('600');

    test('accepts up to the pending balance compared in cents', () {
      expect(RegisterPaymentDialog.validateAmount('600', pending), isNull);
      expect(RegisterPaymentDialog.validateAmount('599,99', pending), isNull);
      expect(RegisterPaymentDialog.validateAmount('0.01', pending), isNull);
    });

    test('rejects pending + 0.01, zero, empty and more than 2 decimals', () {
      expect(
        RegisterPaymentDialog.validateAmount('600.01', pending),
        'El abono no puede superar el saldo pendiente (máximo S/. 600.00)',
      );
      expect(RegisterPaymentDialog.validateAmount('0', pending),
          'El monto debe ser mayor a 0');
      expect(RegisterPaymentDialog.validateAmount('', pending),
          'Ingrese el monto del abono');
      expect(RegisterPaymentDialog.validateAmount('10.555', pending),
          'Ingrese un monto válido (máx. 2 decimales)');
    });
  });

  for (final entry in paymentTestSizes.entries) {
    final size = entry.value;

    group('RegisterPaymentDialog (${entry.key})', () {
      testWidgets('pre-fills the pending balance and rejects pending + 0.01',
          (tester) async {
        final repo = FakePaymentsInvoiceRepository([_partialInvoice()]);
        await _openDialog(tester, size, repo);

        expect(
          find.descendant(of: _amount, matching: find.text('600.00')),
          findsOneWidget,
        );
        expect(find.text('S/. 600.00'), findsOneWidget);

        await _enterAmount(tester, '600.01');
        await _selectMethod(tester, 'Efectivo');
        await _tapSubmit(tester);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'El abono no puede superar el saldo pendiente (máximo S/. 600.00)',
          ),
          findsOneWidget,
        );
        expect(repo.registered, isEmpty);
        expect(find.byType(RegisterPaymentDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('clears the amount error as soon as the amount is fixed',
          (tester) async {
        final repo = FakePaymentsInvoiceRepository([_partialInvoice()]);
        await _openDialog(tester, size, repo);

        await _enterAmount(tester, '600.01');
        await _selectMethod(tester, 'Efectivo');
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        const error =
            'El abono no puede superar el saldo pendiente (máximo S/. 600.00)';
        expect(find.text(error), findsOneWidget);

        await _enterAmount(tester, '600.00');

        expect(find.text(error), findsNothing);
        expect(repo.registered, isEmpty);
        expect(tester.takeException(), isNull);
      });

      testWidgets('requires a payment method', (tester) async {
        final repo = FakePaymentsInvoiceRepository([_partialInvoice()]);
        await _openDialog(tester, size, repo);

        await _tapSubmit(tester);
        await tester.pumpAndSettle();

        expect(find.text('Seleccione un método de pago'), findsOneWidget);
        expect(repo.registered, isEmpty);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'a double tap sends one request and the dialog cannot be closed '
          'while it is in flight', (tester) async {
        final repo = FakePaymentsInvoiceRepository([_partialInvoice()]);
        final pending = Completer<void>();
        repo.onRegister = (invoiceId, payment) async {
          await pending.future;
          return repo.applyPayment(invoiceId, payment.amount, 'Efectivo');
        };
        await _openDialog(tester, size, repo);

        await _selectMethod(tester, 'Efectivo');
        await _tapSubmit(tester);
        await tester.tap(_submit, warnIfMissed: false);
        await tester.pump();
        await tester.tap(_submit, warnIfMissed: false);
        await tester.pump();

        expect(repo.registered, hasLength(1));
        expect(tester.widget<ElevatedButton>(_submit).onPressed, isNull);

        await tester.tapAt(const Offset(4, 4));
        await tester.pump();
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.byType(RegisterPaymentDialog), findsOneWidget);

        pending.complete();
        await tester.pumpAndSettle();

        expect(repo.registered, hasLength(1));
        expect(find.byType(RegisterPaymentDialog), findsNothing);
        expect(find.text('Abono registrado correctamente'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await flushSnackBar(tester);
      });

      testWidgets('on success closes, refreshes the list and shows a SnackBar',
          (tester) async {
        final repo = FakePaymentsInvoiceRepository([_partialInvoice()]);
        await _openDialog(tester, size, repo);
        final loadsBefore = repo.getAllCalls;

        await _selectMethod(tester, 'Transferencia');
        await tester.ensureVisible(_notes);
        await tester.enterText(_notes, '  Pago final  ');
        await _tapSubmit(tester);
        await tester.pumpAndSettle();

        final sent = repo.registered.single;
        expect(sent.amount, Money.parse('600'));
        expect(sent.paymentMethodId, 9);
        expect(sent.notes, 'Pago final');
        expect(sent.requestId, matches(uuidV4Pattern));

        expect(find.byType(RegisterPaymentDialog), findsNothing);
        expect(find.text('Abono registrado correctamente'), findsOneWidget);
        expect(repo.getAllCalls, greaterThan(loadsBefore));
        expect(find.text('S/. 950.00 / S/. 950.00'), findsOneWidget);
        expect(find.text('Pagado'), findsOneWidget);
        expect(
          find.byKey(InvoiceItemView.registerPaymentButtonKey(4)),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
        await flushSnackBar(tester);
      });

      testWidgets(
          'an identical retry reuses the requestId and changed data gets a '
          'new one', (tester) async {
        final repo = FakePaymentsInvoiceRepository([_partialInvoice()]);
        var failures = 4;
        repo.onRegister = (invoiceId, payment) async {
          if (failures-- > 0) {
            throw const PaymentApiException(
                503, 'Servicio de pagos no disponible');
          }
          return repo.applyPayment(invoiceId, payment.amount, 'Transferencia');
        };
        await _openDialog(tester, size, repo);

        await _selectMethod(tester, 'Efectivo');
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        expect(find.text('Servicio de pagos no disponible'), findsOneWidget);
        expect(find.byType(RegisterPaymentDialog), findsOneWidget);

        // Mismos datos: mismo requestId.
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        // Otro monto: requestId nuevo.
        await _enterAmount(tester, '100');
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        // Se repite el último intento: vuelve a usarse su requestId.
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        // Otro método: requestId nuevo.
        await _selectMethod(tester, 'Transferencia');
        await _tapSubmit(tester);
        await tester.pumpAndSettle();

        final ids = repo.registered.map((p) => p.requestId).toList();
        expect(ids, hasLength(5));
        expect(ids, everyElement(matches(uuidV4Pattern)));
        expect(ids[1], ids[0]);
        expect(ids[2], isNot(ids[0]));
        expect(ids[3], ids[2]);
        expect(ids[4], isNot(ids[2]));
        expect(ids[4], isNot(ids[0]));
        expect(repo.registered[2].amount, Money.parse('100'));

        expect(find.byType(RegisterPaymentDialog), findsNothing);
        expect(find.text('Abono registrado correctamente'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await flushSnackBar(tester);
      });

      testWidgets(
          'a 409 shows the server message, keeps the dialog open and '
          'refreshes the balance', (tester) async {
        final repo = FakePaymentsInvoiceRepository([_partialInvoice()]);
        repo.onRegister = (invoiceId, payment) async {
          // Otro usuario registró S/. 400.00 mientras tanto.
          repo.applyPayment(invoiceId, Money.parse('400'), 'Efectivo');
          throw const PaymentApiException(
            409,
            'El abono (S/. 600.00) excede el saldo pendiente (S/. 200.00)',
          );
        };
        await _openDialog(tester, size, repo);
        final loadsBefore = repo.getAllCalls;

        await _selectMethod(tester, 'Efectivo');
        await _tapSubmit(tester);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'El abono (S/. 600.00) excede el saldo pendiente (S/. 200.00)',
          ),
          findsOneWidget,
        );
        expect(find.byType(RegisterPaymentDialog), findsOneWidget);
        expect(repo.getAllCalls, greaterThan(loadsBefore));
        expect(find.text('S/. 200.00'), findsOneWidget);
        expect(find.text('S/. 750.00 / S/. 950.00'), findsOneWidget);

        // Con el saldo actualizado, el mismo monto ya no pasa la validación.
        await _tapSubmit(tester);
        await tester.pumpAndSettle();
        expect(
          find.text(
            'El abono no puede superar el saldo pendiente (máximo S/. 200.00)',
          ),
          findsOneWidget,
        );
        expect(repo.registered, hasLength(1));
        expect(tester.takeException(), isNull);
      });

      for (final status in [201, 200]) {
        testWidgets('HTTP $status from the API counts as success',
            (tester) async {
          SharedPreferences.setMockInitialValues({});
          var paid = false;
          final requests = <http.Request>[];
          final service = InvoiceService(
            'https://example.com/api/',
            client: MockClient((request) async {
              requests.add(request);
              if (request.method == 'POST') {
                paid = true;
                return _json(_invoiceJson(paid: true), status);
              }
              return _json([_invoiceJson(paid: paid)], 200);
            }),
          );

          await _openDialog(tester, size, InvoiceRepositoryImpl(service));
          await _selectMethod(tester, 'Transferencia');
          await _tapSubmit(tester);
          await tester.pumpAndSettle();

          final post = requests.singleWhere((r) => r.method == 'POST');
          expect(post.url.path, '/api/v1/invoices/4/payments');
          final body = jsonDecode(post.body) as Map<String, dynamic>;
          expect(body['amount'], '600.00');
          expect(body['paymentMethodId'], 9);
          expect(body['notes'], isNull);
          expect(body['requestId'], matches(uuidV4Pattern));

          expect(find.byType(RegisterPaymentDialog), findsNothing);
          expect(find.text('Abono registrado correctamente'), findsOneWidget);
          expect(find.text('S/. 950.00 / S/. 950.00'), findsOneWidget);
          expect(find.text('Efectivo · Transferencia'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await flushSnackBar(tester);
        });
      }
    });
  }
}
