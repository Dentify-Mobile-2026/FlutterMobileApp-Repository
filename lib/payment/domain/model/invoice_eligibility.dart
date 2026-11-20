import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment_status.dart';

/// Una cita se puede cobrar si no fue cancelada ni marcada como "No asistió" y
/// todavía no tiene comprobante. Las citas "Atendida" (COMPLETED) sí se cobran.
bool isAppointmentInvoiceable(
  Appointment appointment,
  Set<int> invoicedAppointmentIds,
) {
  final status = appointment.statusEnum;
  if (status == AppointmentStatus.cancelled ||
      status == AppointmentStatus.noShow) {
    return false;
  }
  return !invoicedAppointmentIds.contains(appointment.id);
}

/// Citas cobrables, de la más reciente a la más antigua (sin fecha al final).
List<Appointment> invoiceableAppointments(
  Iterable<Appointment> appointments,
  Iterable<int> invoicedAppointmentIds,
) {
  final invoiced = invoicedAppointmentIds.toSet();
  final result = appointments
      .where((a) => isAppointmentInvoiceable(a, invoiced))
      .toList();
  result.sort((a, b) {
    final da = a.startDateTime;
    final db = b.startDateTime;
    if (da == null && db == null) return b.id.compareTo(a.id);
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  });
  return result;
}
