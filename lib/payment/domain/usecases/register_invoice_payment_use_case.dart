import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/register_payment.dart';
import 'package:dentify_flutter/payment/domain/repository/invoice_repository.dart';

class RegisterInvoicePaymentUseCase {
  final InvoiceRepository repository;

  RegisterInvoicePaymentUseCase(this.repository);

  /// Devuelve el comprobante actualizado (saldo, estado y métodos).
  Future<Invoice> call(int invoiceId, RegisterPayment payment) {
    return repository.registerPayment(invoiceId, payment);
  }
}
