import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:flutter/material.dart';

/// Estado de cobro de un comprobante según sus abonos.
enum InvoiceStatus {
  pending(
    code: 'PENDING',
    label: 'Pendiente',
    color: AppColors.warning,
    bgColor: AppColors.warningLight,
  ),
  partial(
    code: 'PARTIAL',
    label: 'Parcial',
    color: AppColors.info,
    bgColor: AppColors.infoLight,
  ),
  paid(
    code: 'PAID',
    label: 'Pagado',
    color: AppColors.success,
    bgColor: AppColors.successLight,
  );

  final String code;
  final String label;
  final Color color;
  final Color bgColor;

  const InvoiceStatus({
    required this.code,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  /// Pendiente o Parcial: todavía queda saldo por cobrar.
  bool get hasPendingBalance => this != InvoiceStatus.paid;

  /// Estado a partir del código del backend; `null` si falta o no se reconoce.
  static InvoiceStatus? tryParse(String? raw) {
    final normalized = raw?.trim().toUpperCase();
    for (final status in InvoiceStatus.values) {
      if (status.code == normalized) return status;
    }
    return null;
  }

  /// Estado deducido de los montos cuando el servidor no lo informa: sin saldo
  /// es Pagado; con saldo, Parcial si ya se abonó algo y Pendiente si no.
  static InvoiceStatus fromAmounts({
    required Money paid,
    required Money pending,
  }) {
    if (!pending.isPositive) return InvoiceStatus.paid;
    return paid.isPositive ? InvoiceStatus.partial : InvoiceStatus.pending;
  }
}
