import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';

/// Cuerpo de `POST v1/invoices`.
class CreateInvoiceRequest {
  final int appointmentId;
  final Money amount;
  final int paymentMethodId;

  const CreateInvoiceRequest({
    required this.appointmentId,
    required this.amount,
    required this.paymentMethodId,
  });

  factory CreateInvoiceRequest.fromDomain(NewInvoice invoice) {
    return CreateInvoiceRequest(
      appointmentId: invoice.appointmentId,
      amount: invoice.amount,
      paymentMethodId: invoice.paymentMethodId,
    );
  }

  /// Único punto que decide cómo viaja el monto en el JSON.
  ///
  /// Hoy se envía como string decimal exacto (`"120.50"`) para no pasar por
  /// `double`. Si el backend pasara a exigir un número, basta con devolver
  /// `num.parse(amount.toApiString())` aquí.
  static Object encodeAmount(Money amount) => amount.toApiString();

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'amount': encodeAmount(amount),
      'paymentMethodId': paymentMethodId,
    };
  }
}
