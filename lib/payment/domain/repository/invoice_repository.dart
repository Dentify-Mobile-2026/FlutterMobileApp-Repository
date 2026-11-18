import '../../data/remote/dto/add_invoice_request.dart';
import '../../domain/model/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getAllInvoices();
  Future<void> addInvoice(AddInvoiceRequest addInvoiceRequest);
}
