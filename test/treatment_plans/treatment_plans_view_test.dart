import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/patient.dart';
import 'package:dentify_flutter/patientAttention/treatment_plans/data/di/treatment_plans_module.dart';
import 'package:dentify_flutter/patientAttention/treatment_plans/domain/model/plan_amount.dart';
import 'package:dentify_flutter/patientAttention/treatment_plans/domain/model/treatment_plan.dart';
import 'package:dentify_flutter/patientAttention/treatment_plans/domain/repositories/treatment_plan_repository.dart';
import 'package:dentify_flutter/patientAttention/treatment_plans/presentation/views/treatment_plans_view.dart';
import 'package:dentify_flutter/patientAttention/treatment_plans/presentation/widgets/treatment_plan_form.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_status_request.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/widgets/appointment_status_dialog.dart';
import 'package:dentify_flutter/patientAttention/treatments/data/di/dependency_injection.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/repositories/treatment_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const patient = Patient(
    id: 3,
    dni: '12345678',
    firstName: 'Ana',
    lastName: 'Paciente',
    email: 'ana@example.com',
    homeAddress: '',
    birthday: '2000-01-01');
const treatment = Treatment(
    id: 4,
    name: 'Restauración de pieza dental con resina',
    description: '',
    category: 'RESTORATIVE',
    price: 120.50,
    estimatedDurationMinutes: 30,
    isActive: true);

class Catalog extends Fake implements TreatmentRepository {
  @override
  Future<List<Treatment>> getAllTreatments() async => [treatment];
}

class Plans extends Fake implements TreatmentPlanRepository {
  @override
  Future<List<TreatmentPlan>> getPlans(int patientId) async => [
        TreatmentPlan(
            id: 1,
            title: 'Rehabilitación oral con múltiples piezas dentales',
            notes: 'Control de evolución clínica',
            status: 'APPROVED',
            totalAmount: const PlanAmount(24100),
            completedItems: 0,
            totalItems: 2,
            items: List.generate(
                2,
                (i) => TreatmentPlanItem(
                    id: i + 1,
                    treatmentId: 4,
                    treatmentName: treatment.name,
                    itemStatus: 'PENDING',
                    toothNumber: '1${i + 1}',
                    agreedPrice: const PlanAmount(12050))))
      ];
}

void main() {
  for (final width in [375.0, 1280.0]) {
    testWidgets('plans render without overflow at $width px', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(ProviderScope(
          overrides: [
            treatmentPlanRepositoryProvider.overrideWithValue(Plans()),
          ],
          child: MaterialApp(
              theme: AppTheme.light,
              home: const TreatmentPlansView(patient: patient))));
      await tester.pumpAndSettle();
      expect(find.text('S/. 241.00'), findsOneWidget);
      expect(find.textContaining('0/2 sesiones'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('quote form calculates a two-piece quote at $width px',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      TreatmentPlanDraft? saved;
      await tester.pumpWidget(ProviderScope(
          overrides: [treatmentRepositoryProvider.overrideWithValue(Catalog())],
          child: MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                  body: Builder(
                      builder: (context) => TextButton(
                          onPressed: () => showDialog<void>(
                              context: context,
                              builder: (_) =>
                                  TreatmentPlanForm(onSave: (draft) async {
                                    saved = draft;
                                  })),
                          child: const Text('Abrir')))))));
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Título del plan'), 'Plan dental');
      for (var i = 0; i < 2; i++) {
        final dropdown = find.byType(DropdownButtonFormField<int>).at(i);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text(treatment.name).last);
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.text('Total: S/. 241.00'));
      expect(find.text('Total: S/. 241.00'), findsOneWidget);
      await tester.ensureVisible(find.text('Crear presupuesto'));
      await tester.tap(find.text('Crear presupuesto'));
      await tester.pumpAndSettle();
      expect(saved?.items.length, 2);
      expect(saved?.total.cents, 24100);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'completed appointment returns the explicit history opt-in on mobile',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    UpdateAppointmentStatusRequest? saved;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () async {
                      saved = await showDialog<UpdateAppointmentStatusRequest>(
                          context: context,
                          builder: (_) => AppointmentStatusDialog(
                              appointment: Appointment(
                                  id: 1,
                                  patientName: 'Ana Paciente',
                                  dni: '12345678',
                                  appointmentDate: '2026-01-01T10:00:00',
                                  reason: 'Control',
                                  completed: true,
                                  status: 'COMPLETED',
                                  treatmentId: 4,
                                  treatmentName: 'Restauración',
                                  duration: '00:30:00',
                                  createdAt: '2026-01-01T10:00:00')));
                    },
                    child: const Text('Abrir'))))));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Guardar Evolución'));
    await tester.tap(find.text('Guardar Evolución'));
    await tester.pumpAndSettle();
    expect(saved?.recordInMedicalHistory, true);
    expect(tester.takeException(), isNull);
  });
}
