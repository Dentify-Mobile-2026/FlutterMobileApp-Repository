import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/payment/data/di/dependency_injection.dart'
    as payment_data;
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_payment.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_status.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/domain/model/payment_method.dart';
import 'package:dentify_flutter/payment/domain/model/register_payment.dart';
import 'package:dentify_flutter/payment/domain/repository/invoice_repository.dart';
import 'package:dentify_flutter/payment/domain/repository/payment_method_repository.dart';
import 'package:dentify_flutter/payment/presentation/view/invoice_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tamaños en los que se validan las pantallas de pagos.
const paymentTestSizes = {
  'mobile 375x812': Size(375, 812),
  'desktop 1280x800': Size(1280, 800),
};

/// Validador de UUID v4 (RFC 4122) en minúsculas.
final uuidV4Pattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

Invoice testInvoice({
  required int id,
  required String patient,
  required String total,
  String paid = '0',
  InvoiceStatus? status,
  bool legacy = false,
  List<String> methods = const [],
  String? methodName,
  int paymentsCount = 0,
}) {
  final totalAmount = Money.parse(total);
  final paidAmount = Money.parse(paid);
  return Invoice(
    id: id,
    appointmentId: 100 + id,
    patientName: patient,
    dni: '4455${id}000',
    email: '',
    totalAmount: totalAmount,
    paymentMethodName: methodName,
    createdAt: DateTime(2026, 11, 10 + id, 9),
    paidAmount: paidAmount,
    pendingBalance: totalAmount - paidAmount,
    status: status,
    legacy: legacy,
    paymentsCount: paymentsCount,
    paymentMethods: methods,
  );
}

/// Comprobante tras aplicar un abono, como lo devolvería el servidor.
Invoice invoiceWithPayment(Invoice invoice, Money amount, String methodName) {
  final paid = invoice.paidAmount + amount;
  final pending = invoice.pendingBalance - amount;
  return Invoice(
    id: invoice.id,
    appointmentId: invoice.appointmentId,
    patientName: invoice.patientName,
    dni: invoice.dni,
    email: invoice.email,
    totalAmount: invoice.totalAmount,
    paymentMethodName: invoice.paymentMethodName,
    createdAt: invoice.createdAt,
    paidAmount: paid,
    pendingBalance: pending,
    paymentsCount: invoice.paymentsCount + 1,
    paymentMethods: {...invoice.paymentMethods, methodName}.toList(),
  );
}

class FakePaymentsInvoiceRepository implements InvoiceRepository {
  FakePaymentsInvoiceRepository(this.invoices);

  List<Invoice> invoices;
  int getAllCalls = 0;
  final List<NewInvoice> created = [];

  /// Abonos por comprobante, en el orden en que los "devuelve el servidor".
  final Map<int, List<InvoicePayment>> payments = {};
  Object? paymentsError;
  int getPaymentsCalls = 0;

  final List<RegisterPayment> registered = [];

  /// Si se define, decide la respuesta de cada registro de abono; si no, el
  /// abono se aplica al comprobante y se devuelve actualizado.
  Future<Invoice> Function(int invoiceId, RegisterPayment payment)? onRegister;

  @override
  Future<List<Invoice>> getAll() async {
    getAllCalls++;
    return List.of(invoices);
  }

  @override
  Future<void> create(NewInvoice invoice) async {
    created.add(invoice);
  }

  @override
  Future<List<InvoicePayment>> getPayments(int invoiceId) async {
    getPaymentsCalls++;
    final error = paymentsError;
    if (error != null) throw error;
    return List.of(payments[invoiceId] ?? const []);
  }

  @override
  Future<Invoice> registerPayment(int invoiceId, RegisterPayment payment) {
    registered.add(payment);
    final handler = onRegister;
    if (handler != null) return handler(invoiceId, payment);
    return Future.value(applyPayment(invoiceId, payment.amount, 'Efectivo'));
  }

  Invoice applyPayment(int invoiceId, Money amount, String methodName) {
    final index = invoices.indexWhere((invoice) => invoice.id == invoiceId);
    final updated = invoiceWithPayment(invoices[index], amount, methodName);
    invoices = [...invoices]..[index] = updated;
    return updated;
  }
}

class FakePaymentMethodRepository implements PaymentMethodRepository {
  FakePaymentMethodRepository([
    this.methods = const [
      PaymentMethod(id: 7, name: 'Efectivo'),
      PaymentMethod(id: 9, name: 'Transferencia'),
    ],
  ]);

  List<PaymentMethod> methods;
  bool fail = false;

  @override
  Future<List<PaymentMethod>> getAll() async {
    if (fail) throw const PaymentApiException(500, 'Error del servidor');
    return methods;
  }
}

/// Monta [InvoiceView] con los repositorios falsos y el tamaño indicado.
Future<void> pumpInvoiceView(
  WidgetTester tester,
  Size size, {
  required InvoiceRepository invoices,
  PaymentMethodRepository? methods,
  List<Override> extraOverrides = const [],
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      payment_data.invoiceRepositoryProvider.overrideWithValue(invoices),
      payment_data.paymentMethodRepositoryProvider
          .overrideWithValue(methods ?? FakePaymentMethodRepository()),
      ...extraOverrides,
    ],
    child: MaterialApp(theme: AppTheme.light, home: const InvoiceView()),
  ));
  await tester.pumpAndSettle();
}

/// Deja vencer el SnackBar de confirmación para no dejar timers pendientes.
Future<void> flushSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}
