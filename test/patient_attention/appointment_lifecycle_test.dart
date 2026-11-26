import 'dart:convert';

import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment_conflict_exception.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/widgets/appointment_status_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Appointment _appointment({
  required DateTime start,
  String status = 'SCHEDULED',
  bool completed = false,
}) {
  return Appointment(
    id: 1,
    patientName: 'Ana Paciente',
    dni: '12345678',
    appointmentDate: start.toIso8601String(),
    reason: 'Control',
    completed: completed,
    status: status,
    duration: '00:30',
    createdAt: '2026-11-20T09:00:00',
  );
}

Future<void> _openDialog(
    WidgetTester tester, Appointment appointment, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () => showDialog(
            context: context,
            builder: (_) => AppointmentStatusDialog(appointment: appointment)),
        child: const Text('abrir'),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  group('US05 y US07: citas pasadas', () {
    test('a future appointment can be rescheduled or deleted', () {
      final future =
          _appointment(start: DateTime.now().add(const Duration(days: 1)));
      expect(future.canBeRescheduledOrDeleted, isTrue);
    });

    test('an appointment that already started cannot', () {
      final past =
          _appointment(start: DateTime.now().subtract(const Duration(days: 1)));
      final started = _appointment(
          start: DateTime.now().subtract(const Duration(minutes: 5)));
      expect(past.canBeRescheduledOrDeleted, isFalse);
      expect(started.canBeRescheduledOrDeleted, isFalse);
    });

    test('the service message is shown for a past appointment', () {
      final e = AppointmentConflictException.fromResponseBody(jsonEncode({
        'error': 'No se puede reprogramar una cita que ya pasó.',
        'code': 'PAST_APPOINTMENT',
      }));
      expect(e.message, 'No se puede reprogramar una cita que ya pasó.');
    });
  });

  group('US43: una cita atendida no vuelve atrás', () {
    test('a completed appointment counts as attended', () {
      expect(
          _appointment(start: DateTime(2026, 11, 20, 10), status: 'COMPLETED')
              .isAttended,
          isTrue);
      expect(
          _appointment(start: DateTime(2026, 11, 20, 10), completed: true)
              .isAttended,
          isTrue);
      expect(
          _appointment(start: DateTime(2026, 11, 20, 10)).isAttended, isFalse);
    });

    for (final size in const [Size(375, 812), Size(1280, 800)]) {
      testWidgets(
          'an attended appointment only offers Atendida (${size.width.toInt()} px)',
          (tester) async {
        await _openDialog(
            tester,
            _appointment(
                start: DateTime(2026, 11, 20, 10),
                status: 'COMPLETED',
                completed: true),
            size);

        expect(find.widgetWithText(ChoiceChip, 'Atendida'), findsOneWidget);
        expect(find.widgetWithText(ChoiceChip, 'Reservada'), findsNothing);
        expect(find.widgetWithText(ChoiceChip, 'Cancelada'), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'a future appointment keeps its usual options (${size.width.toInt()} px)',
          (tester) async {
        await _openDialog(
            tester,
            _appointment(start: DateTime.now().add(const Duration(days: 2))),
            size);

        expect(find.widgetWithText(ChoiceChip, 'Reservada'), findsOneWidget);
        expect(find.widgetWithText(ChoiceChip, 'Atendida'), findsOneWidget);
        expect(find.widgetWithText(ChoiceChip, 'Cancelada'), findsOneWidget);
        expect(find.widgetWithText(ChoiceChip, 'En Atención'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
