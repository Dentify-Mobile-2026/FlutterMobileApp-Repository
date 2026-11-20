import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/domain/model/register_payment.dart';
import 'package:dentify_flutter/payment/domain/usecases/create_invoice_use_case.dart';
import 'package:dentify_flutter/payment/domain/usecases/get_all_invoices_use_case.dart';
import 'package:dentify_flutter/payment/domain/usecases/register_invoice_payment_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvoiceViewModel extends StateNotifier<AsyncValue<List<Invoice>>> {
  final GetAllInvoicesUseCase getAllInvoicesUseCase;
  final CreateInvoiceUseCase createInvoiceUseCase;
  final RegisterInvoicePaymentUseCase registerInvoicePaymentUseCase;

  Future<void>? _pendingLoad;

  InvoiceViewModel(
    this.getAllInvoicesUseCase,
    this.createInvoiceUseCase,
    this.registerInvoicePaymentUseCase,
  ) : super(const AsyncValue.loading());

  /// Carga o recarga los comprobantes. Las llamadas concurrentes comparten la
  /// misma petición; durante una recarga se conserva la lista anterior.
  Future<void> load() {
    return _pendingLoad ??= _load().whenComplete(() => _pendingLoad = null);
  }

  Future<void> _load() async {
    state = state.hasValue
        ? const AsyncLoading<List<Invoice>>().copyWithPrevious(state)
        : const AsyncLoading<List<Invoice>>();
    try {
      final invoices = [...await getAllInvoicesUseCase()]
        ..sort((a, b) => b.id.compareTo(a.id));
      if (mounted) state = AsyncValue.data(invoices);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  /// Registra el cobro y recarga la lista. Los errores se relanzan para que la
  /// UI muestre el mensaje del servidor; ante un 409 (la cita ya tenía
  /// comprobante) también se recarga la lista.
  Future<void> create(NewInvoice invoice) async {
    try {
      await createInvoiceUseCase(invoice);
    } on PaymentApiException catch (e) {
      if (e.isConflict) await _reloadAfterWrite();
      rethrow;
    }
    await _reloadAfterWrite();
  }

  /// Registra un abono y devuelve el comprobante actualizado (201 creado o 200
  /// reintento idempotente). Siempre recarga la lista, también ante un error,
  /// para que la UI muestre el saldo vigente; los errores se relanzan.
  Future<Invoice> registerPayment(int invoiceId, RegisterPayment payment) async {
    final Invoice updated;
    try {
      updated = await registerInvoicePaymentUseCase(invoiceId, payment);
    } catch (_) {
      await _reloadAfterWrite();
      rethrow;
    }
    _replaceInvoice(updated);
    await _reloadAfterWrite();
    return updated;
  }

  void _replaceInvoice(Invoice updated) {
    final current = state.valueOrNull;
    if (!mounted || current == null) return;
    state = AsyncValue.data([
      for (final invoice in current) invoice.id == updated.id ? updated : invoice,
    ]);
  }

  Future<void> _reloadAfterWrite() async {
    // Una carga iniciada antes de la escritura podría traer datos viejos.
    final pending = _pendingLoad;
    if (pending != null) await pending;
    await load();
  }
}
