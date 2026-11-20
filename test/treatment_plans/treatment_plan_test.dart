import 'dart:convert';
import 'package:dentify_flutter/patientAttention/treatment_plans/data/dto/treatment_plan_dto.dart';
import 'package:dentify_flutter/patientAttention/treatment_plans/data/services/treatment_plan_service.dart';
import 'package:dentify_flutter/patientAttention/treatment_plans/domain/model/plan_amount.dart';
import 'package:dentify_flutter/patientAttention/treatment_plans/domain/model/treatment_plan.dart';
import 'package:dentify_flutter/patientAttention/appointments/data/remote/dto/update_appointment_status_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('sums cents and serializes exact decimal prices', () {
    final draft = TreatmentPlanDraft(title: 'Plan', notes: '', items: [
      PlanItemDraft(
          treatmentId: 1, agreedPrice: PlanAmount.tryParse('120,50')!),
      PlanItemDraft(
          treatmentId: 1,
          toothNumber: '11',
          agreedPrice: PlanAmount.tryParse('0.10')!),
    ]);
    expect(draft.total.formatted, 'S/. 120.60');
    expect(
        (TreatmentPlanDto.toJson(draft)['items'] as List).first['agreedPrice'],
        '120.50');
    for (final invalid in ['-1', 'NaN', '1.001', '1e5', '', '1000000000']) {
      expect(PlanAmount.tryParse(invalid), isNull);
    }
  });

  test('status requests preserve legacy behavior unless explicitly opted in',
      () {
    expect(
        const UpdateAppointmentStatusRequest(status: 'COMPLETED')
            .toJson()['recordInMedicalHistory'],
        false);
    expect(
        const UpdateAppointmentStatusRequest(
                status: 'COMPLETED', recordInMedicalHistory: true)
            .toJson()['recordInMedicalHistory'],
        true);
  });

  test('service uses authenticated API paths and preserves decimal strings',
      () async {
    final service = TreatmentPlanService('https://clinic.example/api/',
        accessToken: () async => 'test-token',
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/patients/3/treatment-plans');
          expect(request.headers['Authorization'], 'Bearer test-token');
          expect(jsonDecode(request.body)['items'][0]['agreedPrice'], '120.50');
          return http.Response('{}', 201);
        }));
    addTearDown(service.close);
    await service.request('POST', 'patients/3/treatment-plans', {
      'items': [
        {'agreedPrice': '120.50'}
      ]
    });
  });

  test('service surfaces rejected requests instead of returning an empty list',
      () async {
    final service = TreatmentPlanService('https://clinic.example/api/',
        accessToken: () async => null,
        client: MockClient(
            (_) async => http.Response('{"error":"Plan no encontrado"}', 404)));
    addTearDown(service.close);
    expect(
        () => service.request('GET', 'patients/3/treatment-plans'),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('Plan no encontrado'))));
  });
}
