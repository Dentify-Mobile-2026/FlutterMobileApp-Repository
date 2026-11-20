
import 'package:dentify_flutter/dashboard/data/remote/repository/dashboard_service.dart';
import 'package:dentify_flutter/dashboard/domain/model/dashboard_data.dart';
import 'package:dentify_flutter/dashboard/domain/repository/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardApiService api;

  DashboardRepositoryImpl(this.api);

  @override
  Future<DashboardData> getDashboardData() async {
    final response = await api.getDashboardData();

    return DashboardData(
      lowStockItems: response.lowStockItems?.map(
        (item) => Item(
          name: item.name ?? '',
          stockQuantity: item.stockQuantity ?? 0,
        ),
      ).toList() ?? [],
      recentPayments: response.recentPayments?.map(
        (inv) => Invoice(
          amount: inv.amount ?? 0.0,
          createdAt: inv.createdAt ?? '',
        ),
      ).toList() ?? [],
      recentAppointments: response.recentAppointments?.map(
        (appt) => Appointment(
          reason: appt.reason ?? '',
          appointmentDate: appt.appointmentDate ?? '',
          duration: appt.duration ?? '',
        ),
      ).toList() ?? [],
      analytics: response.analytics == null
          ? null
          : DashboardAnalytics(
              month: response.analytics!.month,
              revenueBySpecialty: response.analytics!.revenueBySpecialty
                  .map(
                    (s) => SpecialtyRevenue(
                      category: s.category,
                      revenue: s.revenue,
                      count: s.count,
                    ),
                  )
                  .toList(),
              attendance: AttendanceMetrics(
                totalAppointments:
                    response.analytics!.attendance.totalAppointments,
                completedCount: response.analytics!.attendance.completedCount,
                cancelledCount: response.analytics!.attendance.cancelledCount,
                noShowCount: response.analytics!.attendance.noShowCount,
                attendanceRate: response.analytics!.attendance.attendanceRate,
              ),
              financials: FinancialSummary(
                totalCollected: response.analytics!.financials.totalCollected,
                pendingBalance: response.analytics!.financials.pendingBalance,
                collectionRate: response.analytics!.financials.collectionRate,
              ),
            ),
    );
  }
}