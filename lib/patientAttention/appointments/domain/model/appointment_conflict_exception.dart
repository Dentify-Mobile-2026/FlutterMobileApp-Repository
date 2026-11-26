import 'dart:convert';

/// El horario elegido se solapa con otra cita del mismo profesional o cae fuera
/// del horario de atención del consultorio (HTTP 409 del backend).
class AppointmentConflictException implements Exception {
  final String message;

  const AppointmentConflictException([
    this.message = 'This time overlaps with another appointment.',
  ]);

  /// Código que envía el servicio cuando la cita cae fuera del horario de atención (US09).
  static const String outsideBusinessHoursCode = 'OUTSIDE_BUSINESS_HOURS';

  /// Interpreta el cuerpo de un 409. Un cruce de citas conserva el mensaje de
  /// siempre; una cita fuera de horario muestra el mensaje del servicio.
  factory AppointmentConflictException.fromResponseBody(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map && decoded['code'] == outsideBusinessHoursCode) {
        final message = decoded['error'];
        return AppointmentConflictException(message is String && message.isNotEmpty
            ? message
            : 'La cita está fuera del horario de atención del consultorio.');
      }
    } catch (_) {}
    return const AppointmentConflictException();
  }

  @override
  String toString() => message;
}
