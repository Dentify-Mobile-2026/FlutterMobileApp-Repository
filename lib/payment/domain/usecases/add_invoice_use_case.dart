import '../../data/remote/dto/add_invoice_request.dart';
import '../../domain/repository/invoice_repository.dart';

class AddInvoiceUseCase {
  final InvoiceRepository repository;

  AddInvoiceUseCase(this.repository);

  Future<void> call(AddInvoiceRequest invoice) async {
    return await repository.addInvoice(invoice);
  }
}
