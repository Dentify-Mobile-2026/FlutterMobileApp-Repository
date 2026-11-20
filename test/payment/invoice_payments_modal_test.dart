import 'package:dentify_flutter/payment/domain/model/invoice_payment.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/presentation/view/invoice_view.dart';
import 'package:dentify_flutter/payment/presentation/widgets/invoice_payments_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'payment_test_support.dart';

final _modal = find.byType(InvoicePaymentsModal);

Finder _inModal(Finder finder) =>
    find.descendant(of: _modal, matching: finder);

String _localStamp(DateTime utc) =>
    DateFormat('dd/MM/yyyy · hh:mm a').format(utc.toLocal());

FakePaymentsInvoiceRepository _repository() {
  final repo = FakePaymentsInvoiceRepository([
    testInvoice(
      id: 4,
      patient: 'Ana Torres',
      total: '950',
      paid: '350',
      methods: ['Efectivo', 'Transferencia'],
      paymentsCount: 2,
    ),
    testInvoice(id: 3, patient: 'Bruno Díaz', total: '400'),
    testInvoice(
      id: 1,
      patient: 'Diego Paz',
      total: '200',
      paid: '200',
      legacy: true,
      methodName: 'Efectivo',
    ),
  ]);
  // El servidor responde del más antiguo al más reciente; aquí llegan
  // desordenados para comprobar que se muestran en orden cronológico.
  repo.payments[4] = [
    InvoicePayment(
      id: 12,
      amount: Money.parse('250'),
      paymentMethodId: 9,
      paymentMethodName: 'Transferencia',
      notes: 'Segundo abono',
      paidAt: DateTime.utc(2026, 11, 30, 15),
    ),
    InvoicePayment(
      id: 11,
      amount: Money.parse('100'),
      paymentMethodId: 7,
      paymentMethodName: 'Efectivo',
      paidAt: DateTime.utc(2026, 11, 28, 14, 30),
    ),
  ];
  return repo;
}

Future<void> _openPayments(WidgetTester tester, int invoiceId) async {
  final button = find.byKey(InvoiceItemView.viewPaymentsButtonKey(invoiceId));
  // La lista es perezosa: en 375 px las últimas tarjetas aún no existen.
  final invoiceList = find.byWidgetPredicate(
    (widget) => widget is ListView && widget.scrollDirection == Axis.vertical,
  );
  await tester.scrollUntilVisible(
    button,
    200,
    scrollable: find
        .descendant(of: invoiceList, matching: find.byType(Scrollable))
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
  expect(_modal, findsOneWidget);
}

void main() {
  for (final entry in paymentTestSizes.entries) {
    final size = entry.value;

    group('InvoicePaymentsModal (${entry.key})', () {
      testWidgets('lists the payments in chronological order', (tester) async {
        final repo = _repository();
        await pumpInvoiceView(tester, size, invoices: repo);
        await _openPayments(tester, 4);

        expect(_inModal(find.text('Ana Torres')), findsOneWidget);
        expect(_inModal(find.text('Abonos del comprobante #4')), findsOneWidget);

        // Resumen: total / pagado / saldo.
        expect(_inModal(find.text('Total')), findsOneWidget);
        expect(_inModal(find.text('S/. 950.00')), findsOneWidget);
        expect(_inModal(find.text('Pagado')), findsOneWidget);
        expect(_inModal(find.text('S/. 350.00')), findsOneWidget);
        expect(_inModal(find.text('Saldo')), findsOneWidget);
        expect(_inModal(find.text('S/. 600.00')), findsOneWidget);

        final first = _inModal(find.text('Efectivo'));
        final second = _inModal(find.text('Transferencia'));
        expect(first, findsOneWidget);
        expect(second, findsOneWidget);
        expect(
          tester.getTopLeft(first).dy,
          lessThan(tester.getTopLeft(second).dy),
        );

        final firstDate = _inModal(
            find.text(_localStamp(DateTime.utc(2026, 11, 28, 14, 30))));
        final secondDate =
            _inModal(find.text(_localStamp(DateTime.utc(2026, 11, 30, 15))));
        expect(firstDate, findsOneWidget);
        expect(secondDate, findsOneWidget);
        expect(
          tester.getTopLeft(firstDate).dy,
          lessThan(tester.getTopLeft(secondDate).dy),
        );

        expect(_inModal(find.text('S/. 100.00')), findsOneWidget);
        expect(_inModal(find.text('S/. 250.00')), findsOneWidget);
        expect(_inModal(find.text('Segundo abono')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows the legacy empty state', (tester) async {
        await pumpInvoiceView(tester, size, invoices: _repository());
        await _openPayments(tester, 1);

        expect(_inModal(find.text('Diego Paz')), findsOneWidget);
        expect(
          _inModal(find.text('Comprobante histórico pagado en su totalidad; '
              'no tiene abonos individuales')),
          findsOneWidget,
        );
        expect(_inModal(find.text('Aún no hay abonos registrados')),
            findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows the regular empty state', (tester) async {
        await pumpInvoiceView(tester, size, invoices: _repository());
        await _openPayments(tester, 3);

        expect(_inModal(find.text('Aún no hay abonos registrados')),
            findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows the error and recovers with Reintentar',
          (tester) async {
        final repo = _repository()
          ..paymentsError =
              const PaymentApiException(404, 'El comprobante no existe.');
        await pumpInvoiceView(tester, size, invoices: repo);
        await _openPayments(tester, 4);

        expect(_inModal(find.text('No se pudieron cargar los abonos.')),
            findsOneWidget);
        expect(_inModal(find.text('El comprobante no existe.')),
            findsOneWidget);

        repo.paymentsError = null;
        await tester.tap(_inModal(find.text('Reintentar')));
        await tester.pumpAndSettle();

        expect(_inModal(find.text('Segundo abono')), findsOneWidget);
        expect(repo.getPaymentsCalls, 2);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
