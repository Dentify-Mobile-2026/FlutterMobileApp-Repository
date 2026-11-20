import 'package:dentify_flutter/core/utils/whatsapp_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WhatsAppHelper', () {
    test('normalizePhone strips formatting and ensures 51 prefix', () {
      expect(WhatsAppHelper.normalizePhone('987 654 321'), '51987654321');
      expect(WhatsAppHelper.normalizePhone('+51 987-654-321'), '51987654321');
      expect(WhatsAppHelper.normalizePhone('51987654321'), '51987654321');
      expect(WhatsAppHelper.normalizePhone('   '), '');
    });

    test('buildAppointmentReminderMessage includes all required clinical fields', () {
      final msg = WhatsAppHelper.buildAppointmentReminderMessage(
        patientName: 'María López',
        appointmentDate: '25/11/2026',
        appointmentTime: '03:30 PM',
        treatment: 'Profilaxis dental',
        clinicName: 'Clínica Sonrisa',
      );

      expect(msg, contains('María López'));
      expect(msg, contains('25/11/2026'));
      expect(msg, contains('03:30 PM'));
      expect(msg, contains('Profilaxis dental'));
      expect(msg, contains('Clínica Sonrisa'));
    });

    test('buildWhatsAppUri constructs https://wa.me/51... with encoded text', () {
      final uri = WhatsAppHelper.buildWhatsAppUri(
        phone: '987654321',
        message: 'Hola María, cita el 25/11 a las 10:00 AM!',
      );

      expect(uri.scheme, 'https');
      expect(uri.host, 'wa.me');
      expect(uri.path, '/51987654321');
      expect(uri.toString(), contains('text=Hola%20Mar%C3%ADa'));
      expect(uri.queryParameters['text'], 'Hola María, cita el 25/11 a las 10:00 AM!');
    });
  });
}
