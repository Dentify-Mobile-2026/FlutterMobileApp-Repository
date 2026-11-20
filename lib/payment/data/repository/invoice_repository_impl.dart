import 'package:dentify_flutter/payment/data/remote/dto/create_invoice_request.dart';
import 'package:dentify_flutter/payment/data/remote/services/invoice_service.dart';
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';
import 'package:dentify_flutter/payment/domain/repository/invoice_repository.dart';

/// No captura errores: la capa de presentación decide cómo mostrarlos.
class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceService invoiceService;

  InvoiceRepositoryImpl(this.invoiceService);

  @override
  Future<List<Invoice>> getAll() async {
    final responses = await invoiceService.getAllInvoices();
    return responses.map((r) => r.toDomain()).toList();
  }

  @override
  Future<void> create(NewInvoice invoice) {
    return invoiceService.createInvoice(CreateInvoiceRequest.fromDomain(invoice));
  }
}
