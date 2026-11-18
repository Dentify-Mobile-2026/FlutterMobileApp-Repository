import '../../data/remote/services/invoice_service.dart';
import '../../domain/model/invoice.dart';
import '../../domain/repository/invoice_repository.dart';
import '../../data/remote/dto/add_invoice_request.dart';

//import 'package:dio/dio.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceService invoiceService;

  InvoiceRepositoryImpl(this.invoiceService);

  @override
  Future<List<Invoice>> getAllInvoices() async {
    try {
      final response = await invoiceService.getAllInvoices();
      return response.map((e) => e.toDomain()).toList();
    } catch (e) {
      print("Error fetching invoices: $e");
      return [];
    }
  }

  @override
  Future<void> addInvoice(AddInvoiceRequest addInvoiceRequest) async {
    try {
      await invoiceService.addInvoice(addInvoiceRequest);
    } catch (e) {
      print("Error adding invoice: $e");
    }
  }
}
