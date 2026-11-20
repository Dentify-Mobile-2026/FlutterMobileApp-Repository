import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/payment/data/di/dependency_injection.dart'
    as payment_data;
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_payment.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/domain/model/register_payment.dart';
import 'package:dentify_flutter/payment/domain/repository/invoice_repository.dart';
import 'package:dentify_flutter/payment/presentation/view/invoice_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedInvoiceRepository implements InvoiceRepository {
  _ScriptedInvoiceRepository(this.responses);

  /// Cada carga consume la siguiente respuesta: una lista o una excepción.
  final List<Object> responses;

  @override
  Future<List<Invoice>> getAll() async {
    final next = responses.length > 1 ? responses.removeAt(0) : responses.first;
    if (next is Exception) throw next;
    return next as List<Invoice>;
  }

  @override
  Future<void> create(NewInvoice invoice) async {}

  @override
  Future<List<InvoicePayment>> getPayments(int invoiceId) async => const [];

  @override
  Future<Invoice> registerPayment(int invoiceId, RegisterPayment payment) =>
      throw UnimplementedError();
}

Future<void> _pumpView(WidgetTester tester, InvoiceRepository repository) async {
  await tester.binding.setSurfaceSize(const Size(375, 812));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      payment_data.invoiceRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(theme: AppTheme.light, home: const InvoiceView()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the server message and recovers with Reintentar',
      (tester) async {
    await _pumpView(
      tester,
      _ScriptedInvoiceRepository([
        const PaymentApiException(500, 'Servicio de pagos no disponible'),
        [
          Invoice(
            id: 1,
            appointmentId: 101,
            patientName: 'Ana Torres',
            dni: '44556677',
            email: '',
            totalAmount: Money.parse('120.5'),
            paymentMethodName: 'Tarjeta de crédito',
            createdAt: DateTime(2026, 11, 19, 14, 30),
          ),
        ],
      ]),
    );

    expect(find.text('Servicio de pagos no disponible'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Torres'), findsOneWidget);
    expect(find.text('Tarjeta de crédito'), findsOneWidget);
    expect(find.text('S/. 120.50'), findsOneWidget);
    expect(
      find.text('1 comprobante · Recaudado S/. 120.50 · Por cobrar S/. 0.00'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an empty state when there are no invoices',
      (tester) async {
    await _pumpView(tester, _ScriptedInvoiceRepository([<Invoice>[]]));

    expect(find.text('Aún no hay comprobantes registrados'), findsOneWidget);
    expect(
      find.text('0 comprobantes · Recaudado S/. 0.00 · Por cobrar S/. 0.00'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
