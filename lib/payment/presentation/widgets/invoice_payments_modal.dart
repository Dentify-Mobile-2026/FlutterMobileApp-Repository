import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_payment.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/presentation/di/presentation_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Hoja inferior con el historial cronológico de abonos de un comprobante.
class InvoicePaymentsModal extends ConsumerWidget {
  final Invoice invoice;

  const InvoicePaymentsModal({super.key, required this.invoice});

  static final DateFormat _paidAtFormat = DateFormat('dd/MM/yyyy · hh:mm a');

  /// Abre la hoja con el mismo estilo que el historial de movimientos de stock.
  static Future<void> show(BuildContext context, Invoice invoice) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => InvoicePaymentsModal(invoice: invoice),
    );
  }

  /// Fecha y hora local del abono (el servidor la envía en UTC).
  static String formatPaidAt(DateTime paidAt) {
    return _paidAtFormat.format(paidAt.toLocal());
  }

  /// Versión vigente del comprobante en la lista (se actualiza tras un abono).
  Invoice _currentInvoice(WidgetRef ref) {
    final invoices = ref.watch(invoicesViewModelProvider).valueOrNull;
    if (invoices != null) {
      for (final candidate in invoices) {
        if (candidate.id == invoice.id) return candidate;
      }
    }
    return invoice;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = _currentInvoice(ref);
    final paymentsState = ref.watch(invoicePaymentsProvider(invoice.id));
    void reload() => ref.invalidate(invoicePaymentsProvider(invoice.id));

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 640,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 19,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.patientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'Abonos del comprobante #${current.id}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar abonos',
                    onPressed: reload,
                    icon: const Icon(Icons.refresh_rounded,
                        size: 20, color: AppColors.muted),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        size: 20, color: AppColors.muted),
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildSummary(current),
              const SizedBox(height: 14),
              Flexible(
                child: paymentsState.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => _buildError(error, reload),
                  data: (payments) {
                    if (payments.isEmpty) return _buildEmpty(current.legacy);
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: payments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) =>
                          _buildPaymentItem(payments[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(Invoice current) {
    final hasBalance = current.pendingBalance.isPositive;
    return Row(
      children: [
        Expanded(
          child: _amountTile(
            label: 'Total',
            amount: current.totalAmount,
            color: AppColors.ink,
            bg: AppColors.surfaceSubtle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _amountTile(
            label: 'Pagado',
            amount: current.paidAmount,
            color: AppColors.success,
            bg: AppColors.successLight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _amountTile(
            label: 'Saldo',
            amount: current.pendingBalance,
            color: hasBalance ? AppColors.warning : AppColors.muted,
            bg: hasBalance ? AppColors.warningLight : AppColors.surfaceSubtle,
          ),
        ),
      ],
    );
  }

  Widget _amountTile({
    required String label,
    required Money amount,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount.format(),
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error, VoidCallback onRetry) {
    final message = error is PaymentApiException
        ? error.message
        : 'Revise su conexión e intente nuevamente.';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36, color: AppColors.danger),
            const SizedBox(height: 8),
            const Text(
              'No se pudieron cargar los abonos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool legacy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              legacy ? Icons.verified_outlined : Icons.payments_outlined,
              size: 38,
              color: AppColors.muted,
            ),
            const SizedBox(height: 8),
            Text(
              legacy
                  ? 'Comprobante histórico pagado en su totalidad; no tiene '
                      'abonos individuales'
                  : 'Aún no hay abonos registrados',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(InvoicePayment payment) {
    final notes = payment.notes;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.successBorder),
            ),
            child: const Icon(
              Icons.payments_outlined,
              size: 17,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.paymentMethodName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatPaidAt(payment.paidAt),
                  style:
                      const TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
                if (notes != null && notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      notes,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: AppColors.successBorder),
            ),
            child: Text(
              payment.amount.format(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
