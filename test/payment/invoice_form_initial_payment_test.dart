import 'dart:convert';

import 'package:dentify_flutter/patientAttention/appointments/data/di/dependency_injection.dart'
    as appointments_data;
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/repositories/appointment_repository.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/di/dependency_injection.dart'
    as treatments_data;
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/repositories/treatment_repository.dart';
import 'package:dentify_flutter/payment/data/remote/dto/create_invoice_request.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';
import 'package:dentify_flutter/payment/presentation/widgets/invoice_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'payment_test_support.dart';

class _FakeAppointmentRepository extends Fake implements AppointmentRepository {
  @override
  Future<List<Appointment>> getAppointments() async => [
        Appointment(
          id: 101,
          patientName: 'Ana Torres',
          dni: '44556677',
          appointmentDate: '2026-11-18T10:00:00',
          reason: 'Control',
          completed: true,
          status: 'COMPLETED',
          treatmentId: 5,
          treatmentName: 'Endodoncia',
          duration: '00:30',
          createdAt: '2026-11-01T09:00:00',
        ),
      ];
}

class _FakeTreatmentRepository extends Fake implements TreatmentRepository {
  @override
  Future<List<Treatment>> getAllTreatments() async => const [
        Treatment(
          id: 5,
          name: 'Endodoncia',
          description: '',
          category: 'ENDODONTICS',
          price: 350.0,
          estimatedDurationMinutes: 60,
          isActive: true,
        ),
      ];
}

final _amount = find.byKey(InvoiceFormDialog.amountFieldKey);
final _initial = find.byKey(InvoiceFormDialog.initialPaymentFieldKey);
final _submit = find.byKey(InvoiceFormDialog.submitButtonKey);

Future<FakePaymentsInvoiceRepository> _openForm(
  WidgetTester tester,
  Size size,
) async {
  final repo = FakePaymentsInvoiceRepository([]);
  await pumpInvoiceView(
    tester,
    size,
    invoices: repo,
    extraOverrides: [
      appointments_data.appointmentRepositoryProvider
          .overrideWithValue(_FakeAppointmentRepository()),
      treatments_data.treatmentRepositoryProvider
          .overrideWithValue(_FakeTreatmentRepository()),
    ],
  );
  await tester.tap(find.text('Nuevo'));
  await tester.pumpAndSettle();
  expect(find.byType(InvoiceFormDialog), findsOneWidget);

  await tester.tap(find.byType(DropdownButtonFormField<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('Ana Torres ·').last);
  await tester.pumpAndSettle();
  return repo;
}

String _text(WidgetTester tester, Finder field) =>
    tester.widget<TextFormField>(field).controller!.text;

Future<void> _enter(WidgetTester tester, Finder field, String text) async {
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> _selectMethod(WidgetTester tester, String name) async {
  final chip = find.descendant(
    of: find.byType(InvoiceFormDialog),
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
  await tester.pumpAndSettle();
}

String _requestBody(NewInvoice invoice) =>
    jsonEncode(CreateInvoiceRequest.fromDomain(invoice).toJson());

void main() {
  group('InvoiceFormDialog.validateInitialPayment', () {
    final total = Money.parse('350');

    test('accepts 0 and amounts up to the total', () {
      expect(InvoiceFormDialog.validateInitialPayment('0', total), isNull);
      expect(InvoiceFormDialog.validateInitialPayment('0,00', total), isNull);
      expect(InvoiceFormDialog.validateInitialPayment('350', total), isNull);
      expect(InvoiceFormDialog.validateInitialPayment('120.5', total), isNull);
    });

    test('rejects more than the total, bad formats and an empty value', () {
      expect(
        InvoiceFormDialog.validateInitialPayment('350.01', total),
        'El abono inicial no puede superar el monto total (S/. 350.00)',
      );
      expect(InvoiceFormDialog.validateInitialPayment('1.234', total),
          'Ingrese un monto válido (máx. 2 decimales)');
      expect(InvoiceFormDialog.validateInitialPayment('', total),
          'Ingrese el abono inicial (puede ser 0)');
    });
  });

  for (final entry in paymentTestSizes.entries) {
    final size = entry.value;

    group('InvoiceFormDialog initial payment (${entry.key})', () {
      testWidgets('mirrors the total until the user edits it', (tester) async {
        await _openForm(tester, size);

        expect(_text(tester, _amount), '350.00');
        expect(_text(tester, _initial), '350.00');

        await _enter(tester, _amount, '400');
        expect(_text(tester, _initial), '400');

        await _enter(tester, _initial, '100');
        await _enter(tester, _amount, '500');
        expect(_text(tester, _initial), '100');
        expect(find.text('Saldo por cobrar: S/. 400.00'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'an initial payment of 0 does not require a method and sends a '
          'null method with "0.00"', (tester) async {
        final repo = await _openForm(tester, size);

        await _enter(tester, _initial, '0');
        expect(
          find.text('Método de pago (no aplica sin abono inicial)'),
          findsOneWidget,
        );
        expect(find.text('Saldo por cobrar: S/. 350.00'), findsOneWidget);

        await _tapSubmit(tester);

        expect(find.text('Seleccione un método de pago'), findsNothing);
        final sent = repo.created.single;
        expect(sent.paymentMethodId, isNull);
        expect(sent.initialPayment, Money.zero);
        expect(sent.amount, Money.parse('350'));
        expect(
          _requestBody(sent),
          '{"appointmentId":101,"amount":"350.00","paymentMethodId":null,'
          '"initialPayment":"0.00"}',
        );
        expect(find.byType(InvoiceFormDialog), findsNothing);
        expect(tester.takeException(), isNull);
        await flushSnackBar(tester);
      });

      testWidgets('drops a previously chosen method when the initial is 0',
          (tester) async {
        final repo = await _openForm(tester, size);

        await _selectMethod(tester, 'Efectivo');
        await _enter(tester, _initial, '0');
        await _tapSubmit(tester);

        expect(repo.created.single.paymentMethodId, isNull);
        expect(tester.takeException(), isNull);
        await flushSnackBar(tester);
      });

      testWidgets('a partial initial payment sends the method and the amount',
          (tester) async {
        final repo = await _openForm(tester, size);

        await _enter(tester, _amount, '950');
        await _enter(tester, _initial, '350');
        expect(find.text('Saldo por cobrar: S/. 600.00'), findsOneWidget);
        await _selectMethod(tester, 'Efectivo');
        await _tapSubmit(tester);

        final sent = repo.created.single;
        expect(sent.paymentMethodId, 7);
        expect(sent.initialPayment, Money.parse('350'));
        expect(
          _requestBody(sent),
          '{"appointmentId":101,"amount":"950.00","paymentMethodId":7,'
          '"initialPayment":"350.00"}',
        );
        expect(tester.takeException(), isNull);
        await flushSnackBar(tester);
      });

      testWidgets('a mirrored full payment still requires a method',
          (tester) async {
        final repo = await _openForm(tester, size);

        await _tapSubmit(tester);
        expect(find.text('Seleccione un método de pago'), findsOneWidget);
        expect(repo.created, isEmpty);

        await _selectMethod(tester, 'Transferencia');
        await _tapSubmit(tester);

        final sent = repo.created.single;
        expect(sent.initialPayment, Money.parse('350'));
        expect(sent.paymentMethodId, 9);
        expect(tester.takeException(), isNull);
        await flushSnackBar(tester);
      });

      testWidgets('rejects an initial payment greater than the total',
          (tester) async {
        final repo = await _openForm(tester, size);

        await _enter(tester, _initial, '350.01');
        await _selectMethod(tester, 'Efectivo');
        await _tapSubmit(tester);

        expect(
          find.text(
            'El abono inicial no puede superar el monto total (S/. 350.00)',
          ),
          findsOneWidget,
        );
        expect(repo.created, isEmpty);
        expect(find.byType(InvoiceFormDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('clears the error as soon as the initial payment is fixed',
          (tester) async {
        final repo = await _openForm(tester, size);

        await _enter(tester, _initial, '350.01');
        await _selectMethod(tester, 'Efectivo');
        await _tapSubmit(tester);
        const error =
            'El abono inicial no puede superar el monto total (S/. 350.00)';
        expect(find.text(error), findsOneWidget);

        await _enter(tester, _initial, '350');

        expect(find.text(error), findsNothing);
        expect(repo.created, isEmpty);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
