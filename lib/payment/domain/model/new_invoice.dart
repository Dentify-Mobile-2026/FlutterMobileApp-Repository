import 'package:dentify_flutter/payment/domain/model/money.dart';

/// Datos necesarios para registrar el cobro de una cita.
class NewInvoice {
  final int appointmentId;
  final Money amount;
  final int paymentMethodId;

  const NewInvoice({
    required this.appointmentId,
    required this.amount,
    required this.paymentMethodId,
  });
}
