import 'package:dentify_flutter/payment/data/model/json_readers.dart';
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_status.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';

class InvoiceResponse {
  final int id;
  final int appointmentId;
  final String patientName;
  final String dni;
  final String email;
  final Money totalAmount;
  final int? paymentMethodId;
  final String? paymentMethodName;
  final String? createdAt;

  /// Campos de abonos; `null` si el servidor no los envía (ver [toDomain]).
  final Money? paidAmount;
  final Money? pendingBalance;
  final InvoiceStatus? status;
  final bool legacy;
  final int paymentsCount;
  final List<String> paymentMethods;

  const InvoiceResponse({
    required this.id,
    required this.appointmentId,
    required this.patientName,
    required this.dni,
    required this.email,
    required this.totalAmount,
    this.paymentMethodId,
    this.paymentMethodName,
    this.createdAt,
    this.paidAmount,
    this.pendingBalance,
    this.status,
    this.legacy = false,
    this.paymentsCount = 0,
    this.paymentMethods = const [],
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    // `totalAmount` es el campo actual; `amount` se mantiene por compatibilidad.
    final rawAmount = readNum(json['totalAmount']) ?? readNum(json['amount']);
    final rawPaid = readNum(json['paidAmount']);
    final rawPending = readNum(json['pendingBalance']);
    return InvoiceResponse(
      id: readInt(json['id']) ?? 0,
      appointmentId: readInt(json['appointmentId']) ?? 0,
      patientName: readString(json['patientName']) ?? 'Paciente',
      dni: readString(json['dni']) ?? '',
      email: readString(json['email']) ?? '',
      totalAmount: rawAmount == null ? Money.zero : Money.fromJson(rawAmount),
      paymentMethodId: readInt(json['paymentMethodId']),
      paymentMethodName: readString(json['paymentMethodName']),
      createdAt: readString(json['createdAt']),
      paidAmount: rawPaid == null ? null : Money.fromJson(rawPaid),
      pendingBalance: rawPending == null ? null : Money.fromJson(rawPending),
      status: InvoiceStatus.tryParse(readString(json['status'])),
      legacy: readBool(json['legacy']) ?? false,
      paymentsCount: readInt(json['paymentsCount']) ?? 0,
      paymentMethods: readStringList(json['paymentMethods']),
    );
  }

  /// Valores por defecto si faltan los campos de abonos: lo pagado es el
  /// total, el saldo es 0 y el estado se deduce de los montos.
  Invoice toDomain() {
    final rawDate = createdAt;
    return Invoice(
      id: id,
      appointmentId: appointmentId,
      patientName: patientName,
      dni: dni,
      email: email,
      totalAmount: totalAmount,
      paymentMethodId: paymentMethodId,
      paymentMethodName: paymentMethodName,
      createdAt: rawDate == null ? null : DateTime.tryParse(rawDate),
      paidAmount: paidAmount,
      pendingBalance: pendingBalance ?? Money.zero,
      status: status,
      legacy: legacy,
      paymentsCount: paymentsCount,
      paymentMethods: paymentMethods,
    );
  }
}
