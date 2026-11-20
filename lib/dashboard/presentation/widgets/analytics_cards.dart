import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/dashboard/domain/model/dashboard_data.dart';
import 'package:dentify_flutter/patientAttention/treatments/domain/model/treatment_category.dart';
import 'package:flutter/material.dart';

class SpecialtyRevenueCard extends StatelessWidget {
  final List<SpecialtyRevenue> items;

  const SpecialtyRevenueCard({super.key, required this.items});

  String _labelFor(String code) {
    if (code.toUpperCase() == 'GENERAL') return 'Consulta General';
    return TreatmentCategory.fromCode(code).label;
  }

  Color _colorFor(String code) {
    if (code.toUpperCase() == 'GENERAL') return AppColors.muted;
    return TreatmentCategory.fromCode(code).color;
  }

  @override
  Widget build(BuildContext context) {
    final maxRevenue = items.fold<double>(
      0.0,
      (prev, e) => e.revenue > prev ? e.revenue : prev,
    );

    return _AnalyticsShell(
      title: 'Ingresos por Especialidad (Mes)',
      icon: Icons.bar_chart_rounded,
      iconColor: AppColors.primary,
      child: items.isEmpty
          ? const Text(
              'Aún no hay ingresos facturados en el mes actual.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            )
          : Column(
              children: items.map((item) {
                final ratio = maxRevenue > 0
                    ? (item.revenue / maxRevenue).clamp(0.04, 1.0)
                    : 0.0;
                final barColor = _colorFor(item.category);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_labelFor(item.category)} (${item.count})',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'S/. ${item.revenue.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 7,
                          backgroundColor: AppColors.surfaceSubtle,
                          valueColor: AlwaysStoppedAnimation(barColor),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class AttendanceRateCard extends StatelessWidget {
  final AttendanceMetrics metrics;

  const AttendanceRateCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final closed = metrics.completedCount +
        metrics.cancelledCount +
        metrics.noShowCount;
    final ratio =
        closed > 0 ? (metrics.attendanceRate / 100.0).clamp(0.0, 1.0) : 0.0;

    return _AnalyticsShell(
      title: 'Tasa de Asistencia (Mes)',
      icon: Icons.how_to_reg_outlined,
      iconColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${metrics.attendanceRate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  closed > 0
                      ? '${metrics.completedCount} de $closed citas cerradas'
                      : '${metrics.totalAppointments} citas en el mes',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor:
                  closed > 0 ? AppColors.dangerLight : AppColors.surfaceSubtle,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _statChip(
                label: 'Atendidas',
                value: metrics.completedCount,
                color: AppColors.success,
                bg: AppColors.successLight,
              ),
              _statChip(
                label: 'Canceladas',
                value: metrics.cancelledCount,
                color: AppColors.danger,
                bg: AppColors.dangerLight,
              ),
              _statChip(
                label: 'No Asistió',
                value: metrics.noShowCount,
                color: AppColors.warning,
                bg: AppColors.warningLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required String label,
    required int value,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class FinancialBalanceCard extends StatelessWidget {
  final FinancialSummary financials;

  const FinancialBalanceCard({super.key, required this.financials});

  @override
  Widget build(BuildContext context) {
    final total = financials.totalCollected + financials.pendingBalance;
    final collectedRatio =
        total > 0 ? (financials.totalCollected / total).clamp(0.0, 1.0) : 0.0;

    return _AnalyticsShell(
      title: 'Recaudado vs Saldo por Cobrar',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _amountTile(
                  label: 'Total Recaudado',
                  amount: financials.totalCollected,
                  color: AppColors.success,
                  bg: AppColors.successLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _amountTile(
                  label: 'Por Cobrar',
                  amount: financials.pendingBalance,
                  color: financials.pendingBalance > 0
                      ? AppColors.warning
                      : AppColors.muted,
                  bg: financials.pendingBalance > 0
                      ? AppColors.warningLight
                      : AppColors.surfaceSubtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: collectedRatio,
              minHeight: 8,
              backgroundColor: total > 0
                  ? AppColors.warningLight
                  : AppColors.surfaceSubtle,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            total > 0
                ? '${financials.collectionRate.toStringAsFixed(1)}% recaudado del total mensual'
                : 'Sin facturación registrada este mes',
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _amountTile({
    required String label,
    required double amount,
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
              'S/. ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsShell extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _AnalyticsShell({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
