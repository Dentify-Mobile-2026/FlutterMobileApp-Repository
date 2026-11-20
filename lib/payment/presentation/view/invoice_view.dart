import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_status.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/payment/presentation/widgets/invoice_form_dialog.dart';
import 'package:dentify_flutter/payment/presentation/widgets/invoice_payments_modal.dart';
import 'package:dentify_flutter/payment/presentation/widgets/register_payment_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Filtros de la lista: "Saldos pendientes" agrupa Pendiente y Parcial.
enum _InvoiceFilter { all, pendingBalance, paid }

class InvoiceView extends ConsumerStatefulWidget {
  const InvoiceView({super.key});

  @override
  ConsumerState<InvoiceView> createState() => _InvoiceViewState();
}

class _InvoiceViewState extends ConsumerState<InvoiceView> {
  _InvoiceFilter _filter = _InvoiceFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  Future<void> _reload() {
    return ref.read(invoicesViewModelProvider.notifier).load();
  }

  Future<void> _openInvoiceForm() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const InvoiceFormDialog(),
    );
    if (!mounted || created != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cobro registrado correctamente')),
    );
  }

  Future<void> _openRegisterPayment(Invoice invoice) async {
    final registered = await RegisterPaymentDialog.show(context, invoice);
    if (!mounted || !registered) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abono registrado correctamente')),
    );
  }

  void _openPayments(Invoice invoice) {
    InvoicePaymentsModal.show(context, invoice);
  }

  bool _matchesFilter(Invoice invoice) {
    switch (_filter) {
      case _InvoiceFilter.all:
        return true;
      case _InvoiceFilter.pendingBalance:
        return invoice.status.hasPendingBalance;
      case _InvoiceFilter.paid:
        return invoice.status == InvoiceStatus.paid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesState = ref.watch(invoicesViewModelProvider);
    final loadedInvoices = invoicesState.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Facturación y Pagos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        _summary(invoicesState),
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Actualizar pagos',
                        visualDensity: VisualDensity.compact,
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh_rounded,
                            color: AppColors.muted),
                      ),
                      const SizedBox(width: 6),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                        ),
                        onPressed: _openInvoiceForm,
                        icon: const Icon(Icons.add, size: 17),
                        label: const Text('Nuevo',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (loadedInvoices != null && loadedInvoices.isNotEmpty)
            _buildFilters(loadedInvoices),
          Expanded(
            child: invoicesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _InvoicesErrorState(
                message: _describeError(error),
                onRetry: _reload,
              ),
              data: (invoices) {
                if (invoices.isEmpty) return const _InvoicesEmptyState();
                final visible = invoices.where(_matchesFilter).toList();
                if (visible.isEmpty) {
                  return _FilteredEmptyState(
                    message: _filter == _InvoiceFilter.paid
                        ? 'No hay comprobantes pagados'
                        : 'No hay comprobantes con saldo pendiente',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final invoice = visible[index];
                    return InvoiceItemView(
                      invoice: invoice,
                      onRegisterPayment: () => _openRegisterPayment(invoice),
                      onViewPayments: () => _openPayments(invoice),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _summary(AsyncValue<List<Invoice>> state) {
    final invoices = state.valueOrNull;
    if (invoices == null) {
      return state.hasError
          ? 'No se pudieron cargar los comprobantes'
          : 'Cargando comprobantes…';
    }
    final collected =
        invoices.fold<Money>(Money.zero, (acc, inv) => acc + inv.paidAmount);
    final receivable = invoices.fold<Money>(
        Money.zero, (acc, inv) => acc + inv.pendingBalance);
    final count = invoices.length;
    return '$count ${count == 1 ? 'comprobante' : 'comprobantes'} · '
        'Recaudado ${collected.format()} · Por cobrar ${receivable.format()}';
  }

  Widget _buildFilters(List<Invoice> invoices) {
    final pendingCount =
        invoices.where((invoice) => invoice.status.hasPendingBalance).length;
    final paidCount = invoices
        .where((invoice) => invoice.status == InvoiceStatus.paid)
        .length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _filterChip(_InvoiceFilter.all, 'Todos (${invoices.length})'),
            _filterChip(
              _InvoiceFilter.pendingBalance,
              'Saldos pendientes ($pendingCount)',
            ),
            _filterChip(_InvoiceFilter.paid, 'Pagados ($paidCount)'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(_InvoiceFilter filter, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        visualDensity: VisualDensity.compact,
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: _filter == filter,
        selectedColor: AppColors.mint,
        onSelected: (_) => setState(() => _filter = filter),
      ),
    );
  }

  String _describeError(Object error) {
    if (error is PaymentApiException) return error.message;
    return 'Revise su conexión e intente nuevamente.';
  }
}

class _InvoicesErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InvoicesErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 38, color: AppColors.danger),
            const SizedBox(height: 8),
            const Text(
              'No se pudieron cargar los comprobantes.',
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
            const SizedBox(height: 12),
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
}

class _InvoicesEmptyState extends StatelessWidget {
  const _InvoicesEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.muted),
            SizedBox(height: 8),
            Text(
              'Aún no hay comprobantes registrados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Cada cobro registrado aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  final String message;

  const _FilteredEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_alt_off_outlined,
                size: 36, color: AppColors.muted),
            const SizedBox(height: 8),
            Text(
              message,
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
}

class InvoiceItemView extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onRegisterPayment;
  final VoidCallback? onViewPayments;

  const InvoiceItemView({
    super.key,
    required this.invoice,
    this.onRegisterPayment,
    this.onViewPayments,
  });

  static Key registerPaymentButtonKey(int invoiceId) =>
      ValueKey('invoice-$invoiceId-register-payment');

  static Key viewPaymentsButtonKey(int invoiceId) =>
      ValueKey('invoice-$invoiceId-view-payments');

  @override
  Widget build(BuildContext context) {
    final createdAt = invoice.createdAt;
    final details = [
      'Cita #${invoice.appointmentId}',
      if (invoice.dni.isNotEmpty) 'DNI ${invoice.dni}',
      if (createdAt != null)
        DateFormat('dd/MM/yyyy').format(createdAt.toLocal()),
    ].join(' · ');
    // Métodos usados en los abonos; los comprobantes sin abonos individuales
    // conservan el método con que se emitieron.
    final methodName = invoice.paymentMethods.isNotEmpty
        ? invoice.paymentMethods.join(' · ')
        : invoice.paymentMethodName;
    final status = invoice.status;
    final isPaid = status == InvoiceStatus.paid;
    final canRegisterPayment =
        invoice.hasPendingBalance && onRegisterPayment != null;

    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.patientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        details,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      if (invoice.email.isNotEmpty)
                        Text(
                          invoice.email,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.muted,
                          ),
                        ),
                      if (methodName != null && methodName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  methodName,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? AppColors.successLight
                            : AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        invoice.totalAmount.format(),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isPaid ? AppColors.success : AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StatusPill(status: status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PaymentProgress(invoice: invoice),
            if (canRegisterPayment || onViewPayments != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  children: [
                    if (canRegisterPayment)
                      TextButton.icon(
                        key: registerPaymentButtonKey(invoice.id),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: onRegisterPayment,
                        icon: const Icon(Icons.add_card_outlined, size: 17),
                        label: const Text('Registrar abono',
                            style: TextStyle(fontSize: 12.5)),
                      ),
                    if (onViewPayments != null)
                      TextButton.icon(
                        key: viewPaymentsButtonKey(invoice.id),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppColors.muted,
                        ),
                        onPressed: onViewPayments,
                        icon: const Icon(Icons.history_rounded, size: 17),
                        label: const Text('Ver abonos',
                            style: TextStyle(fontSize: 12.5)),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final InvoiceStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status.color,
        ),
      ),
    );
  }
}

/// Barra de lo pagado sobre el total, con el texto "pagado / total" y, para
/// comprobantes históricos, una nota aclaratoria.
class _PaymentProgress extends StatelessWidget {
  final Invoice invoice;

  const _PaymentProgress({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final total = invoice.totalAmount.cents;
    final ratio = total > 0
        ? (invoice.paidAmount.cents / total).clamp(0.0, 1.0)
        : (invoice.status == InvoiceStatus.paid ? 1.0 : 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: AppColors.warningLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 2,
          children: [
            Text(
              '${invoice.paidAmount.format()} / '
              '${invoice.totalAmount.format()}',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            if (invoice.legacy)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 13, color: AppColors.muted),
                  SizedBox(width: 4),
                  Text(
                    'Comprobante histórico',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
