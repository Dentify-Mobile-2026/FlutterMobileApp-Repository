import 'package:dentify_flutter/payment/domain/model/invoice_payment.dart';
import 'package:dentify_flutter/payment/domain/repository/invoice_repository.dart';

class GetInvoicePaymentsUseCase {
  final InvoiceRepository repository;

  GetInvoicePaymentsUseCase(this.repository);

  /// Abonos del comprobante en orden cronológico (del más antiguo al más
  /// reciente; a igual fecha, por id).
  Future<List<InvoicePayment>> call(int invoiceId) async {
    final payments = [...await repository.getPayments(invoiceId)];
    payments.sort((a, b) {
      final byDate = a.paidAt.compareTo(b.paidAt);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return payments;
  }
}
