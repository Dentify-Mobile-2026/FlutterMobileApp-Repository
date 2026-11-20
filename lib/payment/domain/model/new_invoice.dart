import 'package:dentify_flutter/payment/domain/model/money.dart';

/// Datos necesarios para registrar el cobro de una cita.
class NewInvoice {
  final int appointmentId;
  final Money amount;

  /// Obligatorio si hay abono inicial; `null` cuando el abono inicial es 0.
  final int? paymentMethodId;

  /// Monto cobrado al emitir el comprobante (0 a [amount]). Si es `null`, el
  /// servidor cobra el total.
  final Money? initialPayment;

  const NewInvoice({
    required this.appointmentId,
    required this.amount,
    required this.paymentMethodId,
    this.initialPayment,
  });
}
