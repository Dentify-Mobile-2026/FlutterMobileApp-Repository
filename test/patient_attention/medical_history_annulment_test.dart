import 'dart:convert';

import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/patients/data/model/medical_history_response.dart';
import 'package:dentify_flutter/patientAttention/patients/data/remote/services/medical_history_service.dart';
import 'package:dentify_flutter/patientAttention/patients/domain/model/medical_history.dart';
import 'package:dentify_flutter/patientAttention/patients/presentation/widgets/medical_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _baseUrl = 'https://example.com/api/';

const _sizes = {
  'mobile 375x812': Size(375, 812),
  'desktop 1280x800': Size(1280, 800),
};

Map<String, dynamic> _entryJson({bool? annulled, String? reason}) => {
      'id': 11,
      'description': 'Restauración',
      'record': 'Resina en la pieza 21',
      'diagnosis': 'Caries',
      'medication': 'Ninguna',
      'createdAt': '2026-11-24T10:00:00',
      'appointmentDate': '2026-11-24T10:00:00',
      'sourceAppointmentId': 5,
      if (annulled != null) 'annulled': annulled,
      if (reason != null) 'annulmentReason': reason,
      if (annulled == true) 'annulledAt': '2026-11-25T09:00:00',
    };

MedicalHistory _entry({bool annulled = false, String? reason}) =>
    MedicalHistoryResponse.fromJson(
            _entryJson(annulled: annulled, reason: reason))
        .toDomain();

Future<void> _pumpCard(WidgetTester tester, Size size, MedicalHistory entry,
    {VoidCallback? onAnnul}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
          body: SingleChildScrollView(
              child:
                  MedicalHistoryCard(medicalHistory: entry, onAnnul: onAnnul))),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'access_token': 'token-123'});
  });

  group('MedicalHistoryResponse', () {
    test('entries created before annulment existed count as valid', () {
      final entry = MedicalHistoryResponse.fromJson(_entryJson()).toDomain();
      expect(entry.annulled, isFalse);
      expect(entry.annulmentReason, isNull);
    });

    test('reads the annulment fields', () {
      final entry =
          _entry(annulled: true, reason: 'Se registró en otro paciente');
      expect(entry.annulled, isTrue);
      expect(entry.annulmentReason, 'Se registró en otro paciente');
      expect(entry.annulledAt, '2026-11-25T09:00:00');
    });
  });

  group('MedicalHistoryService.annulMedicalHistory', () {
    test('sends the reason with PATCH and returns the annulled entry',
        () async {
      http.Request? captured;
      final service =
          MedicalHistoryService(_baseUrl, client: MockClient((request) async {
        captured = request;
        return http.Response.bytes(
            utf8.encode(
                jsonEncode(_entryJson(annulled: true, reason: 'Duplicada'))),
            200);
      }));

      final result = await service.annulMedicalHistory(3, 11, 'Duplicada');

      expect(captured!.method, 'PATCH');
      expect(
          captured!.url.path, '/api/v1/patients/3/medical-histories/11/annul');
      expect(jsonDecode(captured!.body), {'reason': 'Duplicada'});
      expect(captured!.headers['Authorization'], 'Bearer token-123');
      expect(result.annulled, isTrue);
    });

    test('raises the service message when the entry was already annulled',
        () async {
      final service =
          MedicalHistoryService(_baseUrl, client: MockClient((request) async {
        return http.Response.bytes(
            utf8.encode(jsonEncode({
              'error': 'La entrada de la historia clínica ya está anulada'
            })),
            409);
      }));

      expect(
        () => service.annulMedicalHistory(3, 11, 'Otra vez'),
        throwsA(predicate((e) => e.toString().contains('ya está anulada'))),
      );
    });
  });

  for (final entry in _sizes.entries) {
    group('MedicalHistoryCard at ${entry.key}', () {
      testWidgets('a valid entry offers the Anular button', (tester) async {
        var tapped = false;
        await _pumpCard(tester, entry.value, _entry(),
            onAnnul: () => tapped = true);

        await tester.tap(find.byKey(const Key('medical-history-annul')));
        expect(tapped, isTrue);
        expect(find.byKey(const Key('medical-history-annulled')), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'an annulled entry stays visible with its reason and no button',
          (tester) async {
        await _pumpCard(tester, entry.value,
            _entry(annulled: true, reason: 'Se registró en otro paciente'),
            onAnnul: () {});

        expect(
            find.byKey(const Key('medical-history-annulled')), findsOneWidget);
        expect(find.text('Se registró en otro paciente'), findsOneWidget);
        expect(find.text('Resina en la pieza 21'), findsOneWidget);
        expect(find.byKey(const Key('medical-history-annul')), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });
  }

  testWidgets('the annulment dialog requires a reason', (tester) async {
    String? result = 'sin respuesta';
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showDialog<String>(
                context: context,
                builder: (_) => const AnnulMedicalHistoryDialog());
          },
          child: const Text('abrir'),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    final confirm = find.byKey(const Key('annul-confirm'));
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.enterText(
        find.byKey(const Key('annul-reason')), '  Duplicada  ');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);

    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(result, 'Duplicada');
  });
}
