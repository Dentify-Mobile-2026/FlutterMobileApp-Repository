import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';
import 'package:dentify_flutter/payment/domain/repository/invoice_repository.dart';

class CreateInvoiceUseCase {
  final InvoiceRepository repository;

  CreateInvoiceUseCase(this.repository);

  Future<void> call(NewInvoice invoice) {
    return repository.create(invoice);
  }
}
