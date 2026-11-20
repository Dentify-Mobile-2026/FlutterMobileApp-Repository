import 'package:dentify_flutter/payment/data/model/json_readers.dart';
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
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
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    // `totalAmount` es el campo actual; `amount` se mantiene por compatibilidad.
    final rawAmount = readNum(json['totalAmount']) ?? readNum(json['amount']);
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
    );
  }

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
    );
  }
}
