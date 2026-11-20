import 'package:dentify_flutter/patientAttention/appointments/domain/model/appointment.dart';
import 'package:dentify_flutter/patientAttention/appointments/presentation/di/presentation_module.dart'
    as appointments_di;
import 'package:dentify_flutter/payment/data/di/dependency_injection.dart';
import 'package:dentify_flutter/payment/domain/model/invoice.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_eligibility.dart';
import 'package:dentify_flutter/payment/domain/model/invoice_payment.dart';
import 'package:dentify_flutter/payment/domain/model/payment_method.dart';
import 'package:dentify_flutter/payment/domain/usecases/create_invoice_use_case.dart';
import 'package:dentify_flutter/payment/domain/usecases/get_all_invoices_use_case.dart';
import 'package:dentify_flutter/payment/domain/usecases/get_all_payment_methods_use_case.dart';
import 'package:dentify_flutter/payment/domain/usecases/get_invoice_payments_use_case.dart';
import 'package:dentify_flutter/payment/domain/usecases/register_invoice_payment_use_case.dart';
import 'package:dentify_flutter/payment/presentation/viewmodel/invoice_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllInvoicesUseCaseProvider = Provider<GetAllInvoicesUseCase>((ref) {
  return GetAllInvoicesUseCase(ref.read(invoiceRepositoryProvider));
});

final createInvoiceUseCaseProvider = Provider<CreateInvoiceUseCase>((ref) {
  return CreateInvoiceUseCase(ref.read(invoiceRepositoryProvider));
});

final getInvoicePaymentsUseCaseProvider =
    Provider<GetInvoicePaymentsUseCase>((ref) {
  return GetInvoicePaymentsUseCase(ref.read(invoiceRepositoryProvider));
});

final registerInvoicePaymentUseCaseProvider =
    Provider<RegisterInvoicePaymentUseCase>((ref) {
  return RegisterInvoicePaymentUseCase(ref.read(invoiceRepositoryProvider));
});

final getAllPaymentMethodsUseCaseProvider =
    Provider<GetAllPaymentMethodsUseCase>((ref) {
  return GetAllPaymentMethodsUseCase(ref.read(paymentMethodRepositoryProvider));
});

/// Métodos de pago del backend. Se libera al cerrar el formulario para volver a
/// consultarse (y reintentarse) la próxima vez.
final paymentMethodsProvider =
    FutureProvider.autoDispose<List<PaymentMethod>>((ref) {
  return ref.read(getAllPaymentMethodsUseCaseProvider)();
});

final invoicesViewModelProvider =
    StateNotifierProvider<InvoiceViewModel, AsyncValue<List<Invoice>>>((ref) {
  return InvoiceViewModel(
    ref.read(getAllInvoicesUseCaseProvider),
    ref.read(createInvoiceUseCaseProvider),
    ref.read(registerInvoicePaymentUseCaseProvider),
  );
});

/// Abonos de un comprobante, en orden cronológico. Se libera al cerrar el
/// detalle; al registrar un abono se invalida para volver a consultarse.
final invoicePaymentsProvider = FutureProvider.autoDispose
    .family<List<InvoicePayment>, int>((ref, invoiceId) {
  return ref.read(getInvoicePaymentsUseCaseProvider)(invoiceId);
});

/// Citas del módulo de agenda (solo lectura) que aún se pueden cobrar.
final invoiceableAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final appointments = ref.watch(appointments_di.appointmentsViewModelProvider);
  final invoices =
      ref.watch(invoicesViewModelProvider).valueOrNull ?? const <Invoice>[];
  return invoiceableAppointments(
    appointments,
    invoices.map((invoice) => invoice.appointmentId),
  );
});
