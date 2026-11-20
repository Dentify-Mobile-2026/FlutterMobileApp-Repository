import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/domain/model/payment_method.dart';
import 'package:dentify_flutter/payment/domain/model/register_payment.dart';
import 'package:dentify_flutter/payment/domain/model/request_id.dart';
import 'package:dentify_flutter/payment/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/payment/presentation/widgets/payment_method_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Datos del último intento de registro y el `requestId` con que se envió.
typedef _PaymentAttempt = ({
  String requestId,
  int amountCents,
  int methodId,
  String? notes,
});

/// Formulario para registrar un abono sobre un comprobante con saldo. Devuelve
/// `true` al cerrarse si el servidor confirmó el abono.
class RegisterPaymentDialog extends ConsumerStatefulWidget {
  final Invoice invoice;

  const RegisterPaymentDialog({super.key, required this.invoice});

  static const submitButtonKey = ValueKey('register-payment-submit');
  static const amountFieldKey = ValueKey('register-payment-amount');
  static const notesFieldKey = ValueKey('register-payment-notes');
  static const int notesMaxLength = 255;

  /// Abre el diálogo y devuelve `true` si el abono quedó registrado.
  static Future<bool> show(BuildContext context, Invoice invoice) async {
    final registered = await showDialog<bool>(
      context: context,
      builder: (_) => RegisterPaymentDialog(invoice: invoice),
    );
    return registered == true;
  }

  /// El abono debe tener formato válido (máx. 2 decimales), ser mayor a 0 y no
  /// superar el saldo pendiente (comparado en céntimos).
  static String? validateAmount(String? raw, Money pendingBalance) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return 'Ingrese el monto del abono';
    final amount = Money.tryParse(text);
    if (amount == null) return 'Ingrese un monto válido (máx. 2 decimales)';
    if (!amount.isPositive) return 'El monto debe ser mayor a 0';
    if (amount > pendingBalance) {
      return 'El abono no puede superar el saldo pendiente '
          '(máximo ${pendingBalance.format()})';
    }
    return null;
  }

  @override
  ConsumerState<RegisterPaymentDialog> createState() =>
      _RegisterPaymentDialogState();
}

class _RegisterPaymentDialogState extends ConsumerState<RegisterPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _notesController = TextEditingController();

  int? _selectedMethodId;
  bool _isSubmitting = false;
  bool _showMethodError = false;
  String? _submitError;
  _PaymentAttempt? _lastAttempt;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.invoice.pendingBalance.toApiString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Versión vigente del comprobante: tras cada intento se recarga la lista y
  /// el saldo mostrado (y validado) se actualiza.
  Invoice _currentInvoice(List<Invoice>? invoices) {
    if (invoices != null) {
      for (final candidate in invoices) {
        if (candidate.id == widget.invoice.id) return candidate;
      }
    }
    return widget.invoice;
  }

  int? _pickIfPresent(int? id, Iterable<int> ids) {
    return id != null && ids.contains(id) ? id : null;
  }

  String? _normalizedNotes() {
    final notes = _notesController.text.trim();
    return notes.isEmpty ? null : notes;
  }

  /// Reutiliza el `requestId` del último intento si los datos son idénticos
  /// (reintento tras un error: el servidor no duplica el abono); si cambió el
  /// monto, el método o las notas, genera uno nuevo.
  String _requestIdFor(Money amount, int methodId, String? notes) {
    final last = _lastAttempt;
    if (last != null &&
        last.amountCents == amount.cents &&
        last.methodId == methodId &&
        last.notes == notes) {
      return last.requestId;
    }
    final requestId = generateRequestId();
    _lastAttempt = (
      requestId: requestId,
      amountCents: amount.cents,
      methodId: methodId,
      notes: notes,
    );
    return requestId;
  }

  void _clearSubmitError() {
    if (_submitError != null) setState(() => _submitError = null);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final invoice =
        _currentInvoice(ref.read(invoicesViewModelProvider).valueOrNull);
    final methods = ref.read(paymentMethodsProvider).valueOrNull ??
        const <PaymentMethod>[];
    final methodId =
        _pickIfPresent(_selectedMethodId, methods.map((m) => m.id));
    final formValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _showMethodError = methodId == null;
      _submitError = null;
    });
    if (!formValid || methodId == null) return;

    final amount = Money.parse(_amountController.text);
    final notes = _normalizedNotes();
    final payment = RegisterPayment(
      amount: amount,
      paymentMethodId: methodId,
      notes: notes,
      requestId: _requestIdFor(amount, methodId, notes),
    );
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(invoicesViewModelProvider.notifier)
          .registerPayment(invoice.id, payment);
      if (!mounted) return;
      ref.invalidate(invoicePaymentsProvider(invoice.id));
      Navigator.of(context).pop(true);
    } on PaymentApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError =
            'No se pudo registrar el abono. Revise su conexión e intente nuevamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice =
        _currentInvoice(ref.watch(invoicesViewModelProvider).valueOrNull);
    final pendingBalance = invoice.pendingBalance;
    final hasBalance = pendingBalance.isPositive;
    final methodsState = ref.watch(paymentMethodsProvider);
    final selectedMethodId = _pickIfPresent(
      _selectedMethodId,
      (methodsState.valueOrNull ?? const <PaymentMethod>[]).map((m) => m.id),
    );

    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(invoice),
                    const Divider(height: 28),
                    _buildBalance(invoice),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: RegisterPaymentDialog.amountFieldKey,
                      controller: _amountController,
                      enabled: !_isSubmitting,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Monto del abono (S/.) *',
                        hintText: 'Ej: 120.50',
                        prefixIcon: Icon(Icons.payments_outlined, size: 20),
                        errorMaxLines: 2,
                      ),
                      validator: (raw) => RegisterPaymentDialog.validateAmount(
                        raw,
                        pendingBalance,
                      ),
                      onChanged: (_) => _clearSubmitError(),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Método de pago *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PaymentMethodPicker(
                      methodsState: methodsState,
                      selectedMethodId: selectedMethodId,
                      enabled: !_isSubmitting,
                      onSelected: (id) => setState(() {
                        _selectedMethodId = id;
                        _showMethodError = false;
                        _submitError = null;
                      }),
                      onRetry: () => ref.invalidate(paymentMethodsProvider),
                    ),
                    if (_showMethodError && selectedMethodId == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Seleccione un método de pago',
                          style: TextStyle(fontSize: 12, color: AppColors.danger),
                        ),
                      ),
                    const SizedBox(height: 18),
                    TextFormField(
                      key: RegisterPaymentDialog.notesFieldKey,
                      controller: _notesController,
                      enabled: !_isSubmitting,
                      maxLength: RegisterPaymentDialog.notesMaxLength,
                      minLines: 1,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        hintText: 'Ej: Segundo abono del tratamiento',
                        prefixIcon: Icon(Icons.notes_outlined, size: 20),
                        errorMaxLines: 2,
                      ),
                      validator: (raw) => (raw?.trim().length ?? 0) >
                              RegisterPaymentDialog.notesMaxLength
                          ? 'Máximo ${RegisterPaymentDialog.notesMaxLength} caracteres'
                          : null,
                      onChanged: (_) => _clearSubmitError(),
                    ),
                    if (!hasBalance)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Este comprobante ya no tiene saldo pendiente.',
                          style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                        ),
                      ),
                    if (_submitError != null) _buildSubmitError(_submitError!),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          TextButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton.icon(
                            key: RegisterPaymentDialog.submitButtonKey,
                            onPressed:
                                _isSubmitting || !hasBalance ? null : _submit,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_rounded),
                            label: const Text('Registrar abono'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Invoice invoice) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.add_card_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrar abono',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '${invoice.patientName} · Comprobante #${invoice.id}',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Cerrar',
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildBalance(Invoice invoice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo pendiente',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                Text(
                  invoice.pendingBalance.format(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                  ),
                ),
                Text(
                  'Pagado ${invoice.paidAmount.format()} de '
                  '${invoice.totalAmount.format()}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitError(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dangerBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
