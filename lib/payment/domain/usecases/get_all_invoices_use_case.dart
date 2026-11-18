import '../../domain/model/invoice.dart';
import '../../domain/repository/invoice_repository.dart';

class GetAllInvoicesUseCase {
  final InvoiceRepository repository;

  GetAllInvoicesUseCase(this.repository);

  Future<List<Invoice>> call() async {
    return await repository.getAllInvoices();
  }
}
