import 'package:dentify_flutter/payment/domain/model/money.dart';

/// Abono registrado sobre un comprobante.
class InvoicePayment {
  final int id;
  final Money amount;
  final int paymentMethodId;
  final String paymentMethodName;
  final String? notes;

  /// Instante del abono (el servidor lo envía en UTC).
  final DateTime paidAt;

  const InvoicePayment({
    required this.id,
    required this.amount,
    required this.paymentMethodId,
    required this.paymentMethodName,
    this.notes,
    required this.paidAt,
  });
}
