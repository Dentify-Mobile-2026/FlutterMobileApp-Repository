import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/di/presentation_module.dart'
    as appointments_di;
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment.dart';
import 'package:dentify_flutter/patientAttention/treatments/presentation/di/presentation_module.dart'
    as treatments_di;
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/domain/model/new_invoice.dart';
import 'package:dentify_flutter/payment/domain/model/payment_api_exception.dart';
import 'package:dentify_flutter/payment/domain/model/payment_method.dart';
import 'package:dentify_flutter/payment/presentation/di/presentation_module.dart'
    as payment_di;
import 'package:dentify_flutter/payment/presentation/widgets/payment_method_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Formulario para registrar el cobro de una cita. Devuelve `true` al cerrarse
/// si el servidor confirmó el registro.
class InvoiceFormDialog extends ConsumerStatefulWidget {
  const InvoiceFormDialog({super.key});

  static const submitButtonKey = ValueKey('invoice-form-submit');
  static const amountFieldKey = ValueKey('invoice-form-amount');
  static const initialPaymentFieldKey =
      ValueKey('invoice-form-initial-payment');

  /// El monto debe tener formato válido (máx. 2 decimales) y ser mayor a 0.
  static String? validateAmount(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return 'Ingrese el monto a cobrar';
    final amount = Money.tryParse(text);
    if (amount == null) return 'Ingrese un monto válido (máx. 2 decimales)';
    if (!amount.isPositive) return 'El monto debe ser mayor a 0';
    return null;
  }

  /// El abono inicial puede ser 0, debe tener formato válido (máx. 2
  /// decimales) y no superar el monto total (comparado en céntimos).
  static String? validateInitialPayment(String? raw, Money? total) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return 'Ingrese el abono inicial (puede ser 0)';
    final initial = Money.tryParse(text);
    if (initial == null) return 'Ingrese un monto válido (máx. 2 decimales)';
    if (total != null && initial > total) {
      return 'El abono inicial no puede superar el monto total '
          '(${total.format()})';
    }
    return null;
  }

  @override
  ConsumerState<InvoiceFormDialog> createState() => _InvoiceFormDialogState();
}

class _InvoiceFormDialogState extends ConsumerState<InvoiceFormDialog> {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _initialPaymentController = TextEditingController();

  int? _selectedAppointmentId;
  int? _selectedMethodId;
  String? _prefilledAmount;

  /// Mientras el usuario no edite el abono inicial, este refleja el total.
  bool _initialPaymentEdited = false;
  bool _isSubmitting = false;
  bool _showMethodError = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_mirrorTotalIntoInitialPayment);
    Future.microtask(_refreshSources);
  }

  @override
  void dispose() {
    _amountController.removeListener(_mirrorTotalIntoInitialPayment);
    _amountController.dispose();
    _initialPaymentController.dispose();
    super.dispose();
  }

  void _mirrorTotalIntoInitialPayment() {
    if (_initialPaymentEdited) return;
    if (_initialPaymentController.text != _amountController.text) {
      _initialPaymentController.text = _amountController.text;
    }
  }

  /// Sin abono inicial no se registra ningún pago y el método no aplica.
  bool _requiresPaymentMethod(Money? initialPayment) {
    return initialPayment == null || initialPayment.isPositive;
  }

  /// Asegura comprobantes, citas y tratamientos actualizados al abrir el formulario.
  void _refreshSources() {
    if (!mounted) return;
    if (!ref.read(payment_di.invoicesViewModelProvider).hasValue) {
      ref.read(payment_di.invoicesViewModelProvider.notifier).load();
    }
    final appointmentsVm =
        ref.read(appointments_di.appointmentsViewModelProvider.notifier);
    if (!appointmentsVm.isLoading) appointmentsVm.getAllAppointments();

    final treatmentsLoading = ref.read(treatments_di.treatmentLoadingProvider);
    if (!treatmentsLoading &&
        ref.read(treatments_di.treatmentsViewModelProvider).isEmpty) {
      ref
          .read(treatments_di.treatmentsViewModelProvider.notifier)
          .getAllTreatments();
    }
  }

  int? _pickIfPresent(int? id, Iterable<int> ids) {
    return id != null && ids.contains(id) ? id : null;
  }

  Treatment? _treatmentFor(Appointment appointment, List<Treatment> treatments) {
    final treatmentId = appointment.treatmentId;
    if (treatmentId == null) return null;
    for (final treatment in treatments) {
      if (treatment.id == treatmentId) return treatment;
    }
    return null;
  }

  String _appointmentLabel(Appointment appointment, List<Treatment> treatments) {
    final start = appointment.startDateTime;
    final date = start == null ? 'Sin fecha' : _dateFormat.format(start.toLocal());
    final treatmentName = appointment.treatmentName.trim().isNotEmpty
        ? appointment.treatmentName.trim()
        : _treatmentFor(appointment, treatments)?.name ?? 'Consulta general';
    return '${appointment.patientName} · $date · $treatmentName';
  }

  void _onAppointmentSelected(
    int? appointmentId,
    List<Appointment> eligible,
    List<Treatment> treatments,
  ) {
    setState(() {
      _selectedAppointmentId = appointmentId;
      _submitError = null;
    });
    if (appointmentId == null) return;

    final appointment = eligible.firstWhere((a) => a.id == appointmentId);
    final treatment = _treatmentFor(appointment, treatments);
    final price = treatment == null ? null : Money.fromJson(treatment.price);
    final current = _amountController.text.trim();
    final untouched = current.isEmpty || current == _prefilledAmount;

    if (price != null && price.isPositive) {
      // Solo se precarga si el usuario no escribió un monto propio.
      if (untouched) {
        final text = price.toApiString();
        _amountController.text = text;
        _prefilledAmount = text;
      }
    } else if (_prefilledAmount != null && current == _prefilledAmount) {
      _amountController.clear();
      _prefilledAmount = null;
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final eligible = ref.read(payment_di.invoiceableAppointmentsProvider);
    final methods = ref.read(payment_di.paymentMethodsProvider).valueOrNull ??
        const <PaymentMethod>[];
    final appointmentId =
        _pickIfPresent(_selectedAppointmentId, eligible.map((a) => a.id));
    final methodId =
        _pickIfPresent(_selectedMethodId, methods.map((m) => m.id));
    final initialPayment = Money.tryParse(_initialPaymentController.text);
    final methodRequired = _requiresPaymentMethod(initialPayment);
    final formValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _showMethodError = methodRequired && methodId == null;
      _submitError = null;
    });
    if (!formValid ||
        appointmentId == null ||
        initialPayment == null ||
        (methodRequired && methodId == null)) {
      return;
    }

    final amount = Money.parse(_amountController.text);
    setState(() => _isSubmitting = true);

    try {
      await ref.read(payment_di.invoicesViewModelProvider.notifier).create(
            NewInvoice(
              appointmentId: appointmentId,
              amount: amount,
              paymentMethodId: methodRequired ? methodId : null,
              initialPayment: initialPayment,
            ),
          );
      if (!mounted) return;
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
            'No se pudo registrar el cobro. Revise su conexión e intente nuevamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eligible = ref.watch(payment_di.invoiceableAppointmentsProvider);
    final invoicesState = ref.watch(payment_di.invoicesViewModelProvider);
    final appointmentsVm =
        ref.watch(appointments_di.appointmentsViewModelProvider.notifier);
    final treatments = ref.watch(treatments_di.treatmentsViewModelProvider);
    final methodsState = ref.watch(payment_di.paymentMethodsProvider);

    final loadingAppointments = appointmentsVm.isLoading ||
        (invoicesState.isLoading && !invoicesState.hasValue);
    final appointmentsFailed = !loadingAppointments &&
        eligible.isEmpty &&
        appointmentsVm.errorMessage != null;
    final selectedAppointmentId =
        _pickIfPresent(_selectedAppointmentId, eligible.map((a) => a.id));
    final selectedMethodId = _pickIfPresent(
      _selectedMethodId,
      (methodsState.valueOrNull ?? const <PaymentMethod>[]).map((m) => m.id),
    );
    final total = Money.tryParse(_amountController.text);
    final initialPayment = Money.tryParse(_initialPaymentController.text);
    final methodRequired = _requiresPaymentMethod(initialPayment);

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
                    _buildHeader(context),
                    const Divider(height: 28),
                    DropdownButtonFormField<int>(
                      initialValue: selectedAppointmentId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Cita *',
                        prefixIcon: Icon(Icons.event_note_outlined, size: 20),
                        errorMaxLines: 2,
                      ),
                      hint: _singleLine(
                        loadingAppointments
                            ? 'Cargando citas…'
                            : 'Seleccione una cita',
                      ),
                      disabledHint: _singleLine(
                        loadingAppointments
                            ? 'Cargando citas…'
                            : 'No hay citas pendientes de cobro',
                      ),
                      items: [
                        for (final appointment in eligible)
                          DropdownMenuItem<int>(
                            value: appointment.id,
                            child: Text(
                              _appointmentLabel(appointment, treatments),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13.5),
                            ),
                          ),
                      ],
                      selectedItemBuilder: (context) => [
                        for (final appointment in eligible)
                          _singleLine(_appointmentLabel(appointment, treatments)),
                      ],
                      onChanged: _isSubmitting
                          ? null
                          : (id) => _onAppointmentSelected(id, eligible, treatments),
                      validator: (id) =>
                          id == null ? 'Seleccione la cita a cobrar' : null,
                    ),
                    if (appointmentsFailed)
                      PaymentInlineRetry(
                        message: 'No se pudieron cargar las citas.',
                        onRetry: () => appointmentsVm.getAllAppointments(),
                      ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: InvoiceFormDialog.amountFieldKey,
                      controller: _amountController,
                      enabled: !_isSubmitting,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Monto total (S/.) *',
                        hintText: 'Ej: 120.50',
                        prefixIcon: Icon(Icons.payments_outlined, size: 20),
                        errorMaxLines: 2,
                      ),
                      validator: InvoiceFormDialog.validateAmount,
                      // Se reconstruye para actualizar el saldo por cobrar.
                      onChanged: (_) => setState(() => _submitError = null),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: InvoiceFormDialog.initialPaymentFieldKey,
                      controller: _initialPaymentController,
                      enabled: !_isSubmitting,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Abono inicial (S/.)',
                        hintText: 'Ej: 0 o un monto menor al total',
                        prefixIcon:
                            const Icon(Icons.savings_outlined, size: 20),
                        helperText:
                            _initialPaymentHelper(total, initialPayment),
                        errorMaxLines: 2,
                      ),
                      // Mientras refleja el total, el error lo muestra el total.
                      validator: (raw) => _initialPaymentEdited
                          ? InvoiceFormDialog.validateInitialPayment(raw, total)
                          : null,
                      onChanged: (_) => setState(() {
                        _initialPaymentEdited = true;
                        _submitError = null;
                      }),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      methodRequired
                          ? 'Método de pago *'
                          : 'Método de pago (no aplica sin abono inicial)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PaymentMethodPicker(
                      methodsState: methodsState,
                      selectedMethodId:
                          methodRequired ? selectedMethodId : null,
                      enabled: !_isSubmitting && methodRequired,
                      onSelected: (id) => setState(() {
                        _selectedMethodId = id;
                        _showMethodError = false;
                        _submitError = null;
                      }),
                      onRetry: () =>
                          ref.invalidate(payment_di.paymentMethodsProvider),
                    ),
                    if (_showMethodError &&
                        methodRequired &&
                        selectedMethodId == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Seleccione un método de pago',
                          style: TextStyle(fontSize: 12, color: AppColors.danger),
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
                            key: InvoiceFormDialog.submitButtonKey,
                            onPressed: _isSubmitting ? null : _submit,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_rounded),
                            label: const Text('Registrar cobro'),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.point_of_sale_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar cobro',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              Text(
                'Emite el comprobante de pago de una cita',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
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

  /// Saldo que quedará por cobrar si el abono inicial es menor al total.
  String? _initialPaymentHelper(Money? total, Money? initialPayment) {
    if (total == null || initialPayment == null) return null;
    if (initialPayment >= total) return null;
    return 'Saldo por cobrar: ${(total - initialPayment).format()}';
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

  Widget _singleLine(String text) {
    return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
