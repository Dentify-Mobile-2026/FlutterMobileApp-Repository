import 'dart:convert';

import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment_conflict_exception.dart';
import 'package:dentify_flutter/patientAttention/business_hours/data/business_hours_service.dart';
import 'package:dentify_flutter/patientAttention/business_hours/domain/business_day.dart';
import 'package:dentify_flutter/patientAttention/business_hours/presentation/business_hours_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _baseUrl = 'https://example.com/api/';

const _sizes = {
  'mobile 375x812': Size(375, 812),
  'desktop 1280x800': Size(1280, 800),
};

Map<String, dynamic> _proposal({bool configured = false}) => {
      'configured': configured,
      'days': [
        for (final d in BusinessDay.week)
          {
            'dayOfWeek': d,
            'open': d != 'SATURDAY' && d != 'SUNDAY',
            'opensAt': d != 'SATURDAY' && d != 'SUNDAY' ? '09:00' : null,
            'closesAt': d != 'SATURDAY' && d != 'SUNDAY' ? '18:00' : null,
          }
      ],
    };

http.Response _json(Object body, [int status = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), status,
        headers: {'content-type': 'application/json'});

Future<void> _pump(
    WidgetTester tester, Size size, BusinessHoursService service) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: BusinessHoursView(service: service),
  ));
  await tester.pumpAndSettle();
}

/// Desplaza la lista hasta construir el elemento y lo deja completo en pantalla.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200,
      scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'access_token': 'token-123'});
  });

  group('BusinessDay', () {
    test(
        'sorts the days from Monday to Sunday and sends no hours for closed days',
        () {
      final hours = BusinessHours.fromJson({
        'configured': true,
        'days': [
          {'dayOfWeek': 'SUNDAY', 'open': false},
          {
            'dayOfWeek': 'MONDAY',
            'open': true,
            'opensAt': '08:00',
            'closesAt': '13:00'
          },
        ],
      });

      expect(hours.days.map((d) => d.dayOfWeek), ['MONDAY', 'SUNDAY']);
      expect(hours.days.last.toJson(), {
        'dayOfWeek': 'SUNDAY',
        'open': false,
        'opensAt': null,
        'closesAt': null
      });
      expect(hours.days.first.label, 'Lunes');
    });

    test('an open day needs its opening before its closing', () {
      const ok = BusinessDay(
          dayOfWeek: 'MONDAY', open: true, opensAt: '09:00', closesAt: '18:00');
      const wrong = BusinessDay(
          dayOfWeek: 'MONDAY', open: true, opensAt: '18:00', closesAt: '09:00');
      const closed = BusinessDay(dayOfWeek: 'SUNDAY', open: false);

      expect(ok.isValid, isTrue);
      expect(wrong.isValid, isFalse);
      expect(closed.isValid, isTrue);
      expect(closed.copyWith(open: true).opensAt, '09:00');
    });
  });

  group('AppointmentConflictException.fromResponseBody', () {
    test(
        'shows the service message when the appointment is outside business hours',
        () {
      final e = AppointmentConflictException.fromResponseBody(jsonEncode({
        'error': 'El consultorio no atiende ese día.',
        'code': 'OUTSIDE_BUSINESS_HOURS',
      }));
      expect(e.message, 'El consultorio no atiende ese día.');
    });

    test('keeps the usual message for an overlapping appointment', () {
      final e = AppointmentConflictException.fromResponseBody(jsonEncode(
          {'error': 'The selected time overlaps with another appointment'}));
      expect(e.message, const AppointmentConflictException().message);
      expect(AppointmentConflictException.fromResponseBody('not json').message,
          const AppointmentConflictException().message);
    });
  });

  for (final entry in _sizes.entries) {
    group('BusinessHoursView at ${entry.key}', () {
      testWidgets('shows the proposal and the seven days without overflow',
          (tester) async {
        final service = BusinessHoursService(_baseUrl,
            client: MockClient((request) async => _json(_proposal())));

        await _pump(tester, entry.value, service);

        expect(find.text('Horario de atención'), findsOneWidget);
        expect(
            find.byKey(const Key('business-hours-proposal')), findsOneWidget);
        for (final label in ['Lunes', 'Viernes', 'Sábado']) {
          await tester.scrollUntilVisible(find.text(label), 200,
              scrollable: find.byType(Scrollable).first);
          expect(find.text(label), findsOneWidget);
        }
        expect(find.text('Abre 09:00'), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets('opening Saturday and saving sends the seven days',
          (tester) async {
        http.Request? saved;
        final service =
            BusinessHoursService(_baseUrl, client: MockClient((request) async {
          if (request.method == 'PUT') {
            saved = request;
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            return _json({'configured': true, 'days': body['days']});
          }
          return _json(_proposal());
        }));

        await _pump(tester, entry.value, service);
        final saturday = find.byKey(const Key('open-SATURDAY'));
        await _reveal(tester, saturday);
        await tester.pumpAndSettle();
        await tester.tap(saturday);
        await tester.pumpAndSettle();
        final save = find.byKey(const Key('business-hours-save'));
        await _reveal(tester, save);
        await tester.pumpAndSettle();
        await tester.tap(save);
        await tester.pumpAndSettle();

        expect(saved, isNotNull);
        expect(saved!.url.path, '/api/v1/business-hours');
        expect(saved!.headers['Authorization'], 'Bearer token-123');
        final days = (jsonDecode(saved!.body)['days'] as List)
            .cast<Map<String, dynamic>>();
        expect(days, hasLength(7));
        expect(days.firstWhere((d) => d['dayOfWeek'] == 'SATURDAY'), {
          'dayOfWeek': 'SATURDAY',
          'open': true,
          'opensAt': '09:00',
          'closesAt': '18:00'
        });
        expect(find.byKey(const Key('business-hours-proposal')), findsNothing);
        expect(find.textContaining('Horario guardado'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('shows the service error when saving fails', (tester) async {
        final service =
            BusinessHoursService(_baseUrl, client: MockClient((request) async {
          if (request.method == 'PUT') {
            return _json({
              'error': 'La hora de apertura debe ser anterior a la de cierre'
            }, 400);
          }
          return _json(_proposal(configured: true));
        }));

        await _pump(tester, entry.value, service);
        final save = find.byKey(const Key('business-hours-save'));
        await _reveal(tester, save);
        await tester.pumpAndSettle();
        await tester.tap(save);
        await tester.pumpAndSettle();

        expect(
            find.text('La hora de apertura debe ser anterior a la de cierre'),
            findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
