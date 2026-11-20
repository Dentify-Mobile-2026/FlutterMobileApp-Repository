import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_status.dart';
import 'package:dentify_flutter/payment/presentation/view/invoice_view.dart';
import 'package:dentify_flutter/payment/presentation/widgets/invoice_payments_modal.dart';
import 'package:dentify_flutter/payment/presentation/widgets/register_payment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'payment_test_support.dart';

List<Invoice> _invoices() => [
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
        id: 2,
        patient: 'Carla Ruiz',
        total: '120.50',
        paid: '120.50',
        methods: ['Tarjeta'],
        paymentsCount: 1,
      ),
      testInvoice(
        id: 1,
        patient: 'Diego Paz',
        total: '200',
        paid: '200',
        legacy: true,
        methodName: 'Efectivo',
      ),
    ];

Finder _invoiceList() => find.byWidgetPredicate(
      (widget) => widget is ListView && widget.scrollDirection == Axis.vertical,
    );

Future<void> _selectFilter(WidgetTester tester, String label) async {
  final chip = find.widgetWithText(ChoiceChip, label);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

void main() {
  for (final entry in paymentTestSizes.entries) {
    final size = entry.value;

    group('InvoiceView balances (${entry.key})', () {
      testWidgets('summarises collected and receivable amounts in the header',
          (tester) async {
        await pumpInvoiceView(
          tester,
          size,
          invoices: FakePaymentsInvoiceRepository(_invoices()),
        );

        expect(
          find.text(
            '4 comprobantes · Recaudado S/. 670.50 · Por cobrar S/. 1000.00',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows filter counts and filters pending balances',
          (tester) async {
        await pumpInvoiceView(
          tester,
          size,
          invoices: FakePaymentsInvoiceRepository(_invoices()),
        );

        expect(find.widgetWithText(ChoiceChip, 'Todos (4)'), findsOneWidget);
        expect(
          find.widgetWithText(ChoiceChip, 'Saldos pendientes (2)'),
          findsOneWidget,
        );
        expect(find.widgetWithText(ChoiceChip, 'Pagados (2)'), findsOneWidget);

        await _selectFilter(tester, 'Saldos pendientes (2)');

        expect(find.text('Ana Torres'), findsOneWidget);
        expect(find.text('Bruno Díaz'), findsOneWidget);
        expect(find.text('Carla Ruiz'), findsNothing);
        expect(find.text('Diego Paz'), findsNothing);
        expect(find.byType(InvoiceItemView), findsNWidgets(2));
        final statuses = tester
            .widgetList<InvoiceItemView>(find.byType(InvoiceItemView))
            .map((item) => item.invoice.status);
        expect(statuses, [InvoiceStatus.partial, InvoiceStatus.pending]);
        expect(find.text('Parcial'), findsOneWidget);
        expect(find.text('Pendiente'), findsOneWidget);
        expect(find.text('Pagado'), findsNothing);

        await _selectFilter(tester, 'Pagados (2)');

        expect(find.text('Carla Ruiz'), findsOneWidget);
        expect(find.text('Diego Paz'), findsOneWidget);
        expect(find.text('Ana Torres'), findsNothing);
        expect(find.text('Bruno Díaz'), findsNothing);
        expect(find.text('Pagado'), findsNWidgets(2));

        await _selectFilter(tester, 'Todos (4)');

        expect(find.text('Ana Torres'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows progress, methods and the payment actions',
          (tester) async {
        await pumpInvoiceView(
          tester,
          size,
          invoices: FakePaymentsInvoiceRepository(_invoices()),
        );

        expect(find.text('S/. 350.00 / S/. 950.00'), findsOneWidget);
        expect(find.text('Efectivo · Transferencia'), findsOneWidget);
        final progress = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator).first,
        );
        expect(progress.value, closeTo(350 / 950, 1e-9));

        expect(
          find.byKey(InvoiceItemView.registerPaymentButtonKey(4)),
          findsOneWidget,
        );
        expect(
          find.byKey(InvoiceItemView.registerPaymentButtonKey(3)),
          findsOneWidget,
        );
        expect(find.byKey(InvoiceItemView.viewPaymentsButtonKey(4)),
            findsOneWidget);

        await _selectFilter(tester, 'Pagados (2)');

        // PAID (normal y legacy): solo "Ver abonos".
        expect(
          find.byKey(InvoiceItemView.registerPaymentButtonKey(2)),
          findsNothing,
        );
        expect(
          find.byKey(InvoiceItemView.registerPaymentButtonKey(1)),
          findsNothing,
        );
        expect(find.text('Registrar abono'), findsNothing);
        expect(find.byKey(InvoiceItemView.viewPaymentsButtonKey(2)),
            findsOneWidget);
        expect(find.byKey(InvoiceItemView.viewPaymentsButtonKey(1)),
            findsOneWidget);
        expect(find.text('S/. 120.50 / S/. 120.50'), findsOneWidget);
        expect(find.text('S/. 200.00 / S/. 200.00'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('marks legacy invoices as paid historical receipts',
          (tester) async {
        await pumpInvoiceView(
          tester,
          size,
          invoices: FakePaymentsInvoiceRepository([
            testInvoice(
              id: 1,
              patient: 'Diego Paz',
              total: '200',
              paid: '200',
              legacy: true,
              methodName: 'Efectivo',
            ),
          ]),
        );

        expect(find.text('Pagado'), findsOneWidget);
        expect(find.text('Comprobante histórico'), findsOneWidget);
        expect(find.text('Efectivo'), findsOneWidget);
        expect(find.text('Registrar abono'), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('opens the payment dialog and the payments sheet',
          (tester) async {
        await pumpInvoiceView(
          tester,
          size,
          invoices: FakePaymentsInvoiceRepository(_invoices()),
        );

        await tester
            .tap(find.byKey(InvoiceItemView.registerPaymentButtonKey(4)));
        await tester.pumpAndSettle();
        expect(find.byType(RegisterPaymentDialog), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(find.byType(RegisterPaymentDialog), findsNothing);

        await tester.tap(find.byKey(InvoiceItemView.viewPaymentsButtonKey(4)));
        await tester.pumpAndSettle();
        expect(find.byType(InvoicePaymentsModal), findsOneWidget);
        expect(find.text('Abonos del comprobante #4'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('fits every card without overflow, even with long values',
          (tester) async {
        await pumpInvoiceView(
          tester,
          size,
          invoices: FakePaymentsInvoiceRepository([
            testInvoice(
              id: 9,
              patient: 'María Fernanda de los Ángeles Quispe Huamán',
              total: '99999999.99',
              paid: '12345678.90',
              methods: ['Efectivo', 'Transferencia bancaria', 'Tarjeta'],
              paymentsCount: 3,
            ),
            ..._invoices(),
          ]),
        );
        expect(tester.takeException(), isNull);

        final scrollable = find
            .descendant(of: _invoiceList(), matching: find.byType(Scrollable))
            .first;
        await tester.scrollUntilVisible(
          find.text('Diego Paz'),
          200,
          scrollable: scrollable,
        );
        await tester.pumpAndSettle();

        expect(find.text('Comprobante histórico'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
