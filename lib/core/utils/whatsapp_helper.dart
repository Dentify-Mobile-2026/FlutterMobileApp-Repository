import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  WhatsAppHelper._();

  static const String defaultCountryCode = '51';

  /// Normalizes a phone number keeping only digits and ensuring Peru country code `51`.
  static String normalizePhone(String rawPhone) {
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith(defaultCountryCode) && digits.length > 9) {
      return digits;
    }
    return '$defaultCountryCode$digits';
  }

  /// Builds a prefilled Spanish appointment reminder message.
  static String buildAppointmentReminderMessage({
    required String patientName,
    required String appointmentDate,
    required String appointmentTime,
    required String treatment,
    required String clinicName,
  }) {
    final safeName = patientName.trim().isNotEmpty ? patientName.trim() : 'paciente';
    final safeClinic = clinicName.trim().isNotEmpty ? clinicName.trim() : 'Dentify';
    final safeTreatment =
        treatment.trim().isNotEmpty ? treatment.trim() : 'Evaluación odontológica';
    final safeDate =
        appointmentDate.trim().isNotEmpty ? appointmentDate.trim() : 'por confirmar';
    final safeTime =
        appointmentTime.trim().isNotEmpty ? appointmentTime.trim() : 'por confirmar';

    return 'Hola $safeName, te saludamos de $safeClinic. '
        'Te recordamos tu cita odontológica para el $safeDate a las $safeTime '
        'por: $safeTreatment. ¡Te esperamos!';
  }

  /// Builds the `https://wa.me/51{telefono}?text=...` URI with percent-encoded text.
  static Uri buildWhatsAppUri({
    required String phone,
    required String message,
  }) {
    final normalized = normalizePhone(phone);
    final encodedMessage = Uri.encodeComponent(message);
    return Uri.parse('https://wa.me/$normalized?text=$encodedMessage');
  }

  /// Opens WhatsApp / WhatsApp Web with a prefilled appointment reminder.
  static Future<bool> openAppointmentReminder({
    required String phone,
    required String patientName,
    required String appointmentDate,
    required String appointmentTime,
    required String treatment,
    required String clinicName,
  }) async {
    final normalized = normalizePhone(phone);
    if (normalized.isEmpty) return false;

    final message = buildAppointmentReminderMessage(
      patientName: patientName,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      treatment: treatment,
      clinicName: clinicName,
    );
    final uri = buildWhatsAppUri(phone: normalized, message: message);

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
