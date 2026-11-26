import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment_status.dart';

class Appointment {
  final int id;
  final String patientName;
  final String dni;
  final String patientPhone;
  final String appointmentDate;
  final String reason;
  final bool completed;
  final String status;
  final String clinicalNotes;
  final int? treatmentId;
  final String treatmentName;
  final String duration;
  final String createdAt;

  Appointment({
    required this.id,
    required this.patientName,
    required this.dni,
    this.patientPhone = '',
    required this.appointmentDate,
    required this.reason,
    required this.completed,
    this.status = 'SCHEDULED',
    this.clinicalNotes = '',
    this.treatmentId,
    this.treatmentName = '',
    required this.duration,
    required this.createdAt,
  });

  DateTime? get startDateTime => DateTime.tryParse(appointmentDate);

  DateTime? get endDateTime {
    final start = startDateTime;
    if (start == null) return null;
    try {
      final parts = duration.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      return start.add(Duration(hours: hours, minutes: minutes));
    } catch (_) {
      return start.add(const Duration(minutes: 30));
    }
  }

  /// US05 y US07: solo una cita que todavía no empieza se puede reprogramar o eliminar.
  bool get canBeRescheduledOrDeleted => isFuture;

  /// US43: una cita atendida ya no vuelve a otro estado. Igual que el servicio,
  /// basta con la marca de atendida o con el estado COMPLETED.
  bool get isAttended =>
      completed ||
      AppointmentStatus.fromCode(status) == AppointmentStatus.completed;

  /// Indica si la hora programada aún no llega (no se puede iniciar antes para no desfasar la agenda).
  bool get isFuture {
    final start = startDateTime;
    if (start == null) return false;
    return DateTime.now().isBefore(start);
  }

  /// Determina si la cita ya superó su hora de fin pero aún no ha sido marcada como Atendida, Cancelada o No Asistió.
  bool get isTimeOverAndPending {
    final raw = AppointmentStatus.fromCode(status, fallbackCompleted: completed);
    if (raw == AppointmentStatus.completed ||
        raw == AppointmentStatus.cancelled ||
        raw == AppointmentStatus.noShow) {
      return false;
    }
    final end = endDateTime;
    if (end == null) return false;
    return DateTime.now().isAfter(end);
  }

  /// Estado automático según la ventana horaria:
  /// - Si ya fue cerrada (Atendida, Cancelada o No Asistió), mantiene ese estado final.
  /// - Si la hora actual está dentro del bloque [inicio, fin), pasa automáticamente a "En Atención" (IN_PROGRESS).
  /// - Si todavía no llega la hora de inicio, permanece "Reservada" (SCHEDULED) y no puede iniciarse antes.
  AppointmentStatus get statusEnum {
    final raw = AppointmentStatus.fromCode(status, fallbackCompleted: completed);
    if (raw == AppointmentStatus.completed ||
        raw == AppointmentStatus.cancelled ||
        raw == AppointmentStatus.noShow) {
      return raw;
    }

    final start = startDateTime;
    final end = endDateTime;
    if (start != null && end != null) {
      final now = DateTime.now();
      if (!now.isBefore(start) && now.isBefore(end)) {
        return AppointmentStatus.inProgress;
      }
      if (now.isBefore(start)) {
        return AppointmentStatus.scheduled;
      }
    }
    return raw;
  }
}
