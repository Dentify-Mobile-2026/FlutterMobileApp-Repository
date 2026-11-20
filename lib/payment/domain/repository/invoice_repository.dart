import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_payment.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';
import 'package:dentify_flutter/payment/domain/model/register_payment.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getAll();
  Future<void> create(NewInvoice invoice);

  /// Abonos del comprobante. Falla si el comprobante no existe.
  Future<List<InvoicePayment>> getPayments(int invoiceId);

  /// Registra un abono y devuelve el comprobante actualizado.
  Future<Invoice> registerPayment(int invoiceId, RegisterPayment payment);
}
