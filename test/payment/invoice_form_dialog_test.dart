import 'dart:async';

import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/di/dependency_injection.dart'
    as appointments_data;
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/di/dependency_injection.dart'
    as treatments_data;
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/repositories/treatment_repository.dart';
import 'package:dentify_flutter/payment/data/di/dependency_injection.dart'
    as payment_data;
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_payment.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/domain/model/payment_method.dart';
import 'package:dentify_flutter/payment/domain/model/register_payment.dart';
import 'package:dentify_flutter/payment/domain/repository/invoice_repository.dart';
import 'package:dentify_flutter/payment/domain/repository/payment_method_repository.dart';
import 'package:dentify_flutter/payment/presentation/view/invoice_view.dart';
import 'package:dentify_flutter/payment/presentation/widgets/invoice_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeInvoiceRepository implements InvoiceRepository {
  FakeInvoiceRepository(this.invoices);

  List<Invoice> invoices;
  int getAllCalls = 0;
  final List<NewInvoice> created = [];
  Future<void> Function(NewInvoice invoice)? onCreate;

  @override
  Future<List<Invoice>> getAll() async {
    getAllCalls++;
    return List.of(invoices);
  }

  @override
  Future<void> create(NewInvoice invoice) async {
    created.add(invoice);
    final handler = onCreate;
    if (handler != null) await handler(invoice);
  }

  @override
  Future<List<InvoicePayment>> getPayments(int invoiceId) async => const [];

  @override
  Future<Invoice> registerPayment(int invoiceId, RegisterPayment payment) =>
      throw UnimplementedError();
}

class FakePaymentMethodRepository implements PaymentMethodRepository {
  FakePaymentMethodRepository(this.methods);

  List<PaymentMethod> methods;
  bool fail = false;

  @override
  Future<List<PaymentMethod>> getAll() async {
    if (fail) throw const PaymentApiException(500, 'Error del servidor');
    return methods;
  }
}

class FakeAppointmentRepository extends Fake implements AppointmentRepository {
  FakeAppointmentRepository(this.appointments);

  final List<Appointment> appointments;

  @override
  Future<List<Appointment>> getAppointments() async => appointments;
}

class FakeTreatmentRepository extends Fake implements TreatmentRepository {
  FakeTreatmentRepository(this.treatments);

  final List<Treatment> treatments;

  @override
  Future<List<Treatment>> getAllTreatments() async => treatments;
}

Appointment _appointment({
  required int id,
  required String patient,
  required String date,
  required String status,
  int? treatmentId,
  String treatmentName = '',
}) {
  return Appointment(
    id: id,
    patientName: patient,
    dni: '4455$id',
    appointmentDate: date,
    reason: 'Control',
    completed: status == 'COMPLETED',
    status: status,
    treatmentId: treatmentId,
    treatmentName: treatmentName,
    duration: '00:30',
    createdAt: '2026-11-01T09:00:00',
  );
}

Invoice _invoiceFor(int appointmentId, String patient) {
  return Invoice(
    id: appointmentId,
    appointmentId: appointmentId,
    patientName: patient,
    dni: '4455$appointmentId',
    email: 'paciente@example.com',
    totalAmount: Money.parse('120.50'),
    paymentMethodId: 7,
    paymentMethodName: 'Efectivo',
    createdAt: DateTime(2026, 11, 16, 12),
  );
}

class _Harness {
  final invoices = FakeInvoiceRepository([_invoiceFor(103, 'Carla Ruiz')]);

  final methods = FakePaymentMethodRepository(const [
    PaymentMethod(id: 7, name: 'Efectivo'),
    PaymentMethod(id: 9, name: 'Tarjeta de crédito'),
  ]);

  final appointments = FakeAppointmentRepository([
    _appointment(
      id: 101,
      patient: 'Ana Torres',
      date: '2026-11-18T10:00:00',
      status: 'COMPLETED',
      treatmentId: 5,
      treatmentName: 'Endodoncia',
    ),
    _appointment(
      id: 102,
      patient: 'Bruno Díaz',
      date: '2026-11-17T09:00:00',
      status: 'CANCELLED',
    ),
    _appointment(
      id: 103,
      patient: 'Carla Ruiz',
      date: '2026-11-16T11:00:00',
      status: 'COMPLETED',
    ),
    _appointment(
      id: 104,
      patient: 'Diego Paz',
      date: '2026-11-15T08:00:00',
      status: 'NO_SHOW',
    ),
    _appointment(
      id: 105,
      patient: 'Elena Soto',
      date: '2027-01-25T16:30:00',
      status: 'SCHEDULED',
    ),
  ]);

  final treatments = FakeTreatmentRepository(const [
    Treatment(
      id: 5,
      name: 'Endodoncia',
      description: '',
      category: 'ENDODONTICS',
      price: 350.0,
      estimatedDurationMinutes: 60,
      isActive: true,
    ),
  ]);

  Widget build() {
    return ProviderScope(
      overrides: [
        payment_data.invoiceRepositoryProvider.overrideWithValue(invoices),
        payment_data.paymentMethodRepositoryProvider.overrideWithValue(methods),
        appointments_data.appointmentRepositoryProvider
            .overrideWithValue(appointments),
        treatments_data.treatmentRepositoryProvider
            .overrideWithValue(treatments),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const InvoiceView(),
      ),
    );
  }
}

final _submit = find.byKey(InvoiceFormDialog.submitButtonKey);

Future<_Harness> _openDialog(
  WidgetTester tester,
  Size size, {
  _Harness? harness,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final h = harness ?? _Harness();
  await tester.pumpWidget(h.build());
  await tester.pumpAndSettle();

  await tester.tap(find.text('Nuevo'));
  await tester.pumpAndSettle();
  expect(find.byType(InvoiceFormDialog), findsOneWidget);
  return h;
}

Future<void> _selectAppointment(WidgetTester tester, String patient) async {
  await tester.tap(find.byType(DropdownButtonFormField<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('$patient ·').last);
  await tester.pumpAndSettle();
}

Future<void> _selectMethod(WidgetTester tester, String name) async {
  await tester.tap(find.widgetWithText(ChoiceChip, name));
  await tester.pump();
}

Future<void> _tapSubmit(WidgetTester tester) async {
  await tester.ensureVisible(_submit);
  await tester.pump();
  await tester.tap(_submit);
}

List<int?> _dropdownValues(WidgetTester tester) {
  final dropdown =
      tester.widget<DropdownButton<int>>(find.byType(DropdownButton<int>));
  return dropdown.items!.map((item) => item.value).toList();
}

/// Deja vencer el SnackBar de confirmación para no dejar timers pendientes.
Future<void> _flushSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  const sizes = {
    'mobile 375x812': Size(375, 812),
    'desktop 1280x800': Size(1280, 800),
  };

  for (final entry in sizes.entries) {
    final size = entry.value;

    group('InvoiceFormDialog (${entry.key})', () {
      testWidgets('renders method chips from the API and sends the chosen id',
          (tester) async {
        final h = await _openDialog(tester, size);

        expect(find.widgetWithText(ChoiceChip, 'Efectivo'), findsOneWidget);
        expect(
          find.widgetWithText(ChoiceChip, 'Tarjeta de crédito'),
          findsOneWidget,
        );

        await _selectAppointment(tester, 'Ana Torres');
        await _selectMethod(tester, 'Tarjeta de crédito');
        await _tapSubmit(tester);
        await tester.pumpAndSettle();

        expect(h.invoices.created, hasLength(1));
        final sent = h.invoices.created.single;
        expect(sent.paymentMethodId, 9);
        expect(sent.appointmentId, 101);
        expect(sent.amount, Money.parse('350.00'));

        expect(find.byType(InvoiceFormDialog), findsNothing);
        expect(h.invoices.getAllCalls, greaterThanOrEqualTo(2));
        expect(find.text('Cobro registrado correctamente'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _flushSnackBar(tester);
      });

      testWidgets('pre-fills the treatment price when an appointment is chosen',
          (tester) async {
        await _openDialog(tester, size);

        await _selectAppointment(tester, 'Ana Torres');

        expect(find.text('350.00'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'lists COMPLETED appointments without invoice and hides cancelled, '
          'no-show and already invoiced ones', (tester) async {
        await _openDialog(tester, size);

        expect(_dropdownValues(tester), [105, 101]);

        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await tester.pumpAndSettle();

        expect(
          find.text('Ana Torres · 18/11/2026 10:00 · Endodoncia'),
          findsWidgets,
        );
        expect(
          find.text('Elena Soto · 25/01/2027 16:30 · Consulta general'),
          findsWidgets,
        );
        expect(find.textContaining('Bruno Díaz'), findsNothing);
        expect(find.textContaining('Carla Ruiz ·'), findsNothing);
        expect(find.textContaining('Diego Paz'), findsNothing);

        await tester.tap(find.textContaining('Ana Torres ·').last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('double-tapping submit calls create exactly once',
          (tester) async {
        final h = _Harness();
        final pending = Completer<void>();
        h.invoices.onCreate = (_) => pending.future;
        await _openDialog(tester, size, harness: h);

        await _selectAppointment(tester, 'Ana Torres');
        await _selectMethod(tester, 'Efectivo');
        await _tapSubmit(tester);
        await tester.tap(_submit, warnIfMissed: false);
        await tester.pump();
        await tester.tap(_submit, warnIfMissed: false);
        await tester.pump();

        expect(h.invoices.created, hasLength(1));
        expect(
          tester.widget<ElevatedButton>(_submit).onPressed,
          isNull,
          reason: 'submit stays disabled while the request is in flight',
        );

        pending.complete();
        await tester.pumpAndSettle();

        expect(h.invoices.created, hasLength(1));
        expect(find.byType(InvoiceFormDialog), findsNothing);
        expect(tester.takeException(), isNull);
        await _flushSnackBar(tester);
      });

      testWidgets('shows the server message on 409 and refreshes invoices',
          (tester) async {
        final h = _Harness();
        h.invoices.onCreate = (invoice) async {
          // Otro usuario ya registró el comprobante de esta cita.
          h.invoices.invoices = [
            ...h.invoices.invoices,
            _invoiceFor(invoice.appointmentId, 'Ana Torres'),
          ];
          throw const PaymentApiException(
            409,
            'La cita ya tiene un comprobante',
          );
        };
        await _openDialog(tester, size, harness: h);
        final loadsBefore = h.invoices.getAllCalls;

        await _selectAppointment(tester, 'Ana Torres');
        await _selectMethod(tester, 'Tarjeta de crédito');
        await _tapSubmit(tester);
        await tester.pumpAndSettle();

        expect(find.text('La cita ya tiene un comprobante'), findsOneWidget);
        expect(find.byType(InvoiceFormDialog), findsOneWidget);
        expect(h.invoices.getAllCalls, greaterThan(loadsBefore));
        expect(_dropdownValues(tester), [105]);
        expect(tester.takeException(), isNull);
      });

      testWidgets('validates appointment, amount and payment method',
          (tester) async {
        final h = await _openDialog(tester, size);

        await tester.enterText(find.byType(TextFormField), '120.555');
        await _tapSubmit(tester);
        await tester.pumpAndSettle();

        expect(find.text('Seleccione la cita a cobrar'), findsOneWidget);
        expect(
          find.text('Ingrese un monto válido (máx. 2 decimales)'),
          findsOneWidget,
        );
        expect(find.text('Seleccione un método de pago'), findsOneWidget);
        expect(h.invoices.created, isEmpty);
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows an error with retry when payment methods fail',
          (tester) async {
        final h = _Harness();
        h.methods.fail = true;
        await _openDialog(tester, size, harness: h);

        expect(
          find.text('No se pudieron cargar los métodos de pago.'),
          findsOneWidget,
        );
        expect(find.byType(ChoiceChip), findsNothing);

        h.methods.fail = false;
        await tester.tap(find.text('Reintentar'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(ChoiceChip, 'Efectivo'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
