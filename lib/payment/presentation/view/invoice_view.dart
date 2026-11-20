import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/payment/presentation/widgets/invoice_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InvoiceView extends ConsumerStatefulWidget {
  const InvoiceView({super.key});

  @override
  ConsumerState<InvoiceView> createState() => _InvoiceViewState();
}

class _InvoiceViewState extends ConsumerState<InvoiceView> {
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

  @override
  Widget build(BuildContext context) {
    final invoicesState = ref.watch(invoicesViewModelProvider);

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
          Expanded(
            child: invoicesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _InvoicesErrorState(
                message: _describeError(error),
                onRetry: _reload,
              ),
              data: (invoices) {
                if (invoices.isEmpty) return const _InvoicesEmptyState();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    return InvoiceItemView(invoice: invoices[index]);
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
    final total =
        invoices.fold<Money>(Money.zero, (acc, inv) => acc + inv.totalAmount);
    final count = invoices.length;
    return '$count ${count == 1 ? 'comprobante' : 'comprobantes'} · '
        'Total ${total.format()}';
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

class InvoiceItemView extends StatelessWidget {
  final Invoice invoice;

  const InvoiceItemView({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final createdAt = invoice.createdAt;
    final details = [
      'Cita #${invoice.appointmentId}',
      if (invoice.dni.isNotEmpty) 'DNI ${invoice.dni}',
      if (createdAt != null)
        DateFormat('dd/MM/yyyy').format(createdAt.toLocal()),
    ].join(' · ');
    final methodName = invoice.paymentMethodName;

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
        child: Row(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                invoice.totalAmount.format(),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
