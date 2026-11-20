import 'package:dentify_flutter/payment/domain/model/money.dart';

/// Datos para registrar un abono sobre un comprobante.
class RegisterPayment {
  final Money amount;
  final int paymentMethodId;
  final String? notes;

  /// UUID v4 que hace idempotente el registro: reenviar los mismos datos con el
  /// mismo [requestId] no duplica el abono.
  final String requestId;

  const RegisterPayment({
    required this.amount,
    required this.paymentMethodId,
    this.notes,
    required this.requestId,
  });
}
