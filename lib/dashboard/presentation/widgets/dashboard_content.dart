import 'package:dentify_flutter/dashboard/domain/model/dashboard_data.dart';
import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'glassmorphic_card.dart';
import 'circular_stock_indicator.dart';
import 'sparkline_payments.dart';

class DashboardContent extends StatelessWidget {
  final DashboardData data;

  const DashboardContent({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassmorphicCard(
          title: 'Items con Bajo Stock',
          icon: Icons.inventory,
          contentColor: AppColors.warning,
          child: Column(
            children: (data.lowStockItems ?? []).take(3).map((i) =>
              CircularStockIndicator(
                name: i.name ?? "Desconocido",
                stock: i.stockQuantity ?? 0,
                maxStock: 100,
                color: AppColors.warning,
              )
            ).toList(),
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphicCard(
          title: 'Últimos Pagos',
          icon: Icons.payments,
          contentColor: AppColors.success,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total: S/. ${((data.recentPayments ?? []).fold<double>(0.0, (acc, item) => acc + (item.amount ?? 0))).toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              SparklinePayments(
                payments: (data.recentPayments ?? []).map((e) => e.amount ?? 0.0).toList(),
                color: AppColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphicCard(
          title: 'Citas Recientes',
          icon: Icons.calendar_today,
          contentColor: AppColors.primary,
          child: Column(
            children: (data.recentAppointments ?? []).map((a) =>
              ListTile(
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: Text(a.reason ?? 'Sin motivo'),
                subtitle: Text('${a.appointmentDate ?? "Fecha desconocida"} • ${a.duration ?? "N/A"}'),
              )
            ).toList(),
          ),
        ),
      ],
    );
  }
}
