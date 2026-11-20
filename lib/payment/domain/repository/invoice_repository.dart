import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getAll();
  Future<void> create(NewInvoice invoice);
}
