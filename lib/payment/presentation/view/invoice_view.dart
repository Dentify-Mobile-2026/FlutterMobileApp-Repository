import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../../domain/model/invoice.dart';
import '../../presentation/viewmodel/invoice_view_model.dart';

class InvoiceView extends StatefulWidget {
  final InvoiceViewModel viewModel;
  final VoidCallback toAddInvoiceForm;

  const InvoiceView({
    super.key,
    required this.viewModel,
    required this.toAddInvoiceForm,
  });

  @override
  State<InvoiceView> createState() => _InvoiceViewState();
}

class _InvoiceViewState extends State<InvoiceView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.getAllInvoices();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final invoices = widget.viewModel.invoices;
    final total = invoices.fold<double>(0.0, (acc, inv) => acc + inv.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        '${invoices.length} comprobantes · Total S/. ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar pagos',
                  onPressed: () => widget.viewModel.getAllInvoices(),
                  icon:
                      const Icon(Icons.refresh_rounded, color: AppColors.muted),
                ),
                const SizedBox(width: 6),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  ),
                  onPressed: widget.toAddInvoiceForm,
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('Nuevo', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          Expanded(
            child: invoices.isEmpty
                ? const Center(
                    child: Text(
                      'No hay facturas registradas aún.',
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      return InvoiceItemView(invoice: invoices[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class InvoiceItemView extends StatelessWidget {
  final Invoice invoice;

  const InvoiceItemView({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final dateText = invoice.createdAt.length >= 10
        ? invoice.createdAt.substring(0, 10)
        : invoice.createdAt;

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
                    'Cita #${invoice.appointmentId} · DNI ${invoice.dni} · $dateText',
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
                'S/. ${invoice.amount.toStringAsFixed(2)}',
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
