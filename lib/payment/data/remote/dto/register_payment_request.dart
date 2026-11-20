import 'package:dentify_flutter/payment/data/remote/dto/create_invoice_request.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/register_payment.dart';

/// Cuerpo de `POST v1/invoices/{invoiceId}/payments`.
class RegisterPaymentRequest {
  final Money amount;
  final int paymentMethodId;
  final String? notes;
  final String requestId;

  const RegisterPaymentRequest({
    required this.amount,
    required this.paymentMethodId,
    this.notes,
    required this.requestId,
  });

  factory RegisterPaymentRequest.fromDomain(RegisterPayment payment) {
    final notes = payment.notes?.trim();
    return RegisterPaymentRequest(
      amount: payment.amount,
      paymentMethodId: payment.paymentMethodId,
      notes: notes == null || notes.isEmpty ? null : notes,
      requestId: payment.requestId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': CreateInvoiceRequest.encodeAmount(amount),
      'paymentMethodId': paymentMethodId,
      'notes': notes,
      'requestId': requestId,
    };
  }
}
