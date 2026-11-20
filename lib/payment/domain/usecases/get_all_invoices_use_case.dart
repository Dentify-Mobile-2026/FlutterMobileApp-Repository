import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/repository/invoice_repository.dart';

class GetAllInvoicesUseCase {
  final InvoiceRepository repository;

  GetAllInvoicesUseCase(this.repository);

  Future<List<Invoice>> call() {
    return repository.getAll();
  }
}
