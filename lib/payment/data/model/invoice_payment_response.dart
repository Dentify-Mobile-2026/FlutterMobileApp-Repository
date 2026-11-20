import 'package:dentify_flutter/payment/data/model/json_readers.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_payment.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';

class InvoicePaymentResponse {
  final int id;
  final Money amount;
  final int paymentMethodId;
  final String? paymentMethodName;
  final String? notes;
  final String? paidAt;

  const InvoicePaymentResponse({
    required this.id,
    required this.amount,
    required this.paymentMethodId,
    this.paymentMethodName,
    this.notes,
    this.paidAt,
  });

  factory InvoicePaymentResponse.fromJson(Map<String, dynamic> json) {
    final rawAmount = readNum(json['amount']);
    return InvoicePaymentResponse(
      id: readInt(json['id']) ?? 0,
      amount: rawAmount == null ? Money.zero : Money.fromJson(rawAmount),
      paymentMethodId: readInt(json['paymentMethodId']) ?? 0,
      paymentMethodName: readString(json['paymentMethodName']),
      notes: readString(json['notes']),
      paidAt: readString(json['paidAt']),
    );
  }

  /// `paidAt` llega en ISO-8601 UTC; la UI lo muestra con `toLocal()`.
  InvoicePayment toDomain() {
    final rawDate = paidAt;
    final parsedDate = rawDate == null ? null : DateTime.tryParse(rawDate);
    return InvoicePayment(
      id: id,
      amount: amount,
      paymentMethodId: paymentMethodId,
      paymentMethodName: paymentMethodName ??
          (paymentMethodId > 0 ? 'Método #$paymentMethodId' : 'Método de pago'),
      notes: notes,
      paidAt: parsedDate ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
