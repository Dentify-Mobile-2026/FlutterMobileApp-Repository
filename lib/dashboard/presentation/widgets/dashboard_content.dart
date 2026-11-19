import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:dentify_flutter/dashboard/domain/model/dashboard_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sparkline_payments.dart';

class DashboardContent extends StatelessWidget {
  final DashboardData data;

  const DashboardContent({required this.data, super.key});

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Fecha desconocida';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('dd/MM · hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final lowStock = data.lowStockItems ?? [];
    final payments = data.recentPayments ?? [];
    final appointments = data.recentAppointments ?? [];
    final totalRecent =
        payments.fold<double>(0.0, (acc, item) => acc + (item.amount ?? 0));
    final isWide = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panel de Control',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.3,
            ),
          ),
          const Text(
            'Resumen operativo de hoy en tu consultorio',
            style: TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
          const SizedBox(height: 16),

          // KPIs superiores minimalistas
          LayoutBuilder(
            builder: (context, constraints) {
              final kpis = [
                _kpiTile(
                  icon: Icons.payments_outlined,
                  label: 'Ingresos Recientes',
                  value: 'S/. ${totalRecent.toStringAsFixed(2)}',
                  accent: AppColors.primary,
                  bg: AppColors.surfaceSubtle,
                  subtitle: '${payments.length} últimos comprobantes',
                ),
                _kpiTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Citas de Hoy',
                  value: '${appointments.length}',
                  accent: AppColors.primary,
                  bg: AppColors.surfaceSubtle,
                  subtitle: 'Programadas para hoy',
                ),
                _kpiTile(
                  icon: Icons.inventory_2_outlined,
                  label: 'Alertas de Stock',
                  value: '${lowStock.length}',
                  accent: AppColors.primary,
                  bg: AppColors.surfaceSubtle,
                  borderColor:
                      lowStock.isNotEmpty ? AppColors.warningBorder : null,
                  subtitle: 'Insumos con stock crítico',
                ),
              ];
              if (constraints.maxWidth >= 680) {
                return Row(
                  children: [
                    for (int i = 0; i < kpis.length; i++) ...[
                      Expanded(child: kpis[i]),
                      if (i < kpis.length - 1) const SizedBox(width: 12),
                    ],
                  ],
                );
              }
              return Column(
                children: [
                  for (int i = 0; i < kpis.length; i++) ...[
                    kpis[i],
                    if (i < kpis.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _paymentsCard(payments, totalRecent),
                      const SizedBox(height: 12),
                      _appointmentsCard(appointments),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: _lowStockCard(lowStock),
                ),
              ],
            )
          else ...[
            _paymentsCard(payments, totalRecent),
            const SizedBox(height: 12),
            _appointmentsCard(appointments),
            const SizedBox(height: 12),
            _lowStockCard(lowStock),
          ],
        ],
      ),
    );
  }

  Widget _kpiTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
    required Color bg,
    required String subtitle,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: borderColor != null ? 1.3 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
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

  Widget _paymentsCard(List<dynamic> payments, double total) {
    return _sectionCard(
      title: 'Tendencia de Últimos Pagos',
      icon: Icons.show_chart_rounded,
      iconColor: AppColors.success,
      child: payments.isEmpty
          ? const Text(
              'Aún no hay pagos registrados.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SparklinePayments(
                  payments:
                      payments.map<double>((e) => (e.amount ?? 0.0) as double).toList(),
                  color: AppColors.success,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: payments.map((p) {
                    final amt = (p.amount ?? 0.0) as double;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'S/. ${amt.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  Widget _appointmentsCard(List<dynamic> appointments) {
    return _sectionCard(
      title: 'Citas de Hoy',
      icon: Icons.event_note_outlined,
      iconColor: AppColors.primary,
      child: appointments.isEmpty
          ? const Text(
              'No tienes citas programadas para hoy.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            )
          : Column(
              children: appointments.map((a) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.reason ?? 'Consulta dental',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              '${_formatDate(a.appointmentDate)} · ${a.duration ?? "N/A"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _lowStockCard(List<dynamic> lowStock) {
    return _sectionCard(
      title: 'Insumos con Bajo Stock',
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
      child: lowStock.isEmpty
          ? const Text(
              'Todo tu inventario está en niveles óptimos.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            )
          : Column(
              children: lowStock.take(4).map((i) {
                final qty = (i.stockQuantity ?? 0) as int;
                final ratio = (qty / 20.0).clamp(0.05, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              i.name ?? 'Insumo',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: qty <= 3
                                    ? AppColors.dangerBorder
                                    : AppColors.warningBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: qty <= 3
                                        ? AppColors.danger
                                        : AppColors.warning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '$qty uds',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 5,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(
                            qty <= 3 ? AppColors.danger : AppColors.warning,
                          ),
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
