import 'package:dentify_flutter/payment/domain/model/money.dart';

/// Comprobante de pago emitido para una cita.
class Invoice {
  final int id;
  final int appointmentId;
  final String patientName;
  final String dni;
  final String email;
  final Money totalAmount;
  final int? paymentMethodId;
  final String? paymentMethodName;
  final DateTime? createdAt;

  const Invoice({
    required this.id,
    required this.appointmentId,
    required this.patientName,
    required this.dni,
    required this.email,
    required this.totalAmount,
    this.paymentMethodId,
    this.paymentMethodName,
    this.createdAt,
  });
}
