import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';

/// Cuerpo de `POST v1/invoices`.
class CreateInvoiceRequest {
  final int appointmentId;
  final Money amount;
  final int? paymentMethodId;

  /// Si es `null` no se envía y el servidor cobra el total.
  final Money? initialPayment;

  const CreateInvoiceRequest({
    required this.appointmentId,
    required this.amount,
    required this.paymentMethodId,
    this.initialPayment,
  });

  factory CreateInvoiceRequest.fromDomain(NewInvoice invoice) {
    return CreateInvoiceRequest(
      appointmentId: invoice.appointmentId,
      amount: invoice.amount,
      paymentMethodId: invoice.paymentMethodId,
      initialPayment: invoice.initialPayment,
    );
  }

  /// Único punto que decide cómo viaja el monto en el JSON.
  ///
  /// Hoy se envía como string decimal exacto (`"120.50"`) para no pasar por
  /// `double`. Si el backend pasara a exigir un número, basta con devolver
  /// `num.parse(amount.toApiString())` aquí.
  static Object encodeAmount(Money amount) => amount.toApiString();

  Map<String, dynamic> toJson() {
    final initial = initialPayment;
    // Sin abono inicial no se registra ningún pago: el método viaja como null.
    final chargesNow = initial == null || initial.isPositive;
    return {
      'appointmentId': appointmentId,
      'amount': encodeAmount(amount),
      'paymentMethodId': chargesNow ? paymentMethodId : null,
      if (initial != null) 'initialPayment': encodeAmount(initial),
    };
  }
}
