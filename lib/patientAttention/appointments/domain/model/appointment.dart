
class Appointment {
  final int id;
  final String patientName;
  final String dni;
  final String appointmentDate;
  final String reason;
  final bool completed;
  final String duration;
  final String createdAt;

  Appointment(
      {required this.id,
      required this.patientName,
      required this.dni,
      required this.appointmentDate,
      required this.reason,
      required this.completed,
      required this.duration,
      required this.createdAt});
}