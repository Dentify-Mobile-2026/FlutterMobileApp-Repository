/// El horario elegido se solapa con otra cita del mismo profesional (HTTP 409 del backend).
class AppointmentConflictException implements Exception {
  final String message;

  const AppointmentConflictException([
    this.message = 'This time overlaps with another appointment.',
  ]);

  @override
  String toString() => message;
}
