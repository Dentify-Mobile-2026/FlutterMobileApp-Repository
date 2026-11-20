import 'package:dentify_flutter/payment/domain/model/invoice_status.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';

/// Comprobante de pago emitido para una cita.
class Invoice {
  final int id;
  final int appointmentId;
  final String patientName;
  final String dni;
  final String email;
  final Money totalAmount;
  final int? paymentMethodId;
  final String? paymentMethodName;
  final DateTime? createdAt;

  /// Suma de los abonos registrados.
  final Money paidAmount;

  /// Monto que aún falta cobrar.
  final Money pendingBalance;
  final InvoiceStatus status;

  /// Comprobante histórico (anterior a los abonos): cuenta como pagado en su
  /// totalidad y no tiene abonos individuales.
  final bool legacy;
  final int paymentsCount;

  /// Métodos de pago distintos usados en los abonos.
  final List<String> paymentMethods;

  /// Sin datos de abonos, el comprobante se considera pagado en su totalidad
  /// (comportamiento previo a los abonos parciales). Si no se indica [status],
  /// se deduce de los montos; un comprobante [legacy] siempre está pagado.
  Invoice({
    required this.id,
    required this.appointmentId,
    required this.patientName,
    required this.dni,
    required this.email,
    required this.totalAmount,
    this.paymentMethodId,
    this.paymentMethodName,
    this.createdAt,
    Money? paidAmount,
    this.pendingBalance = Money.zero,
    InvoiceStatus? status,
    this.legacy = false,
    this.paymentsCount = 0,
    this.paymentMethods = const [],
  })  : paidAmount = paidAmount ?? totalAmount,
        status = legacy
            ? InvoiceStatus.paid
            : status ??
                InvoiceStatus.fromAmounts(
                  paid: paidAmount ?? totalAmount,
                  pending: pendingBalance,
                );

  bool get hasPendingBalance => pendingBalance.isPositive;
}
