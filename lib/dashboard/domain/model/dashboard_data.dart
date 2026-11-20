class DashboardData {
  final List<Item>? lowStockItems;
  final List<Invoice>? recentPayments;
  final List<Appointment>? recentAppointments;
  final DashboardAnalytics? analytics;

  DashboardData({
    this.lowStockItems,
    this.recentPayments,
    this.recentAppointments,
    this.analytics,
  });
}

class DashboardAnalytics {
  final String month;
  final List<SpecialtyRevenue> revenueBySpecialty;
  final AttendanceMetrics attendance;
  final FinancialSummary financials;

  const DashboardAnalytics({
    required this.month,
    required this.revenueBySpecialty,
    required this.attendance,
    required this.financials,
  });
}

class SpecialtyRevenue {
  final String category;
  final double revenue;
  final int count;

  const SpecialtyRevenue({
    required this.category,
    required this.revenue,
    required this.count,
  });
}

class AttendanceMetrics {
  final int totalAppointments;
  final int completedCount;
  final int cancelledCount;
  final int noShowCount;
  final double attendanceRate;

  const AttendanceMetrics({
    required this.totalAppointments,
    required this.completedCount,
    required this.cancelledCount,
    required this.noShowCount,
    required this.attendanceRate,
  });
}

class FinancialSummary {
  final double totalCollected;
  final double pendingBalance;
  final double collectionRate;

  const FinancialSummary({
    required this.totalCollected,
    required this.pendingBalance,
    required this.collectionRate,
  });
}

class Item {
  final String? name;
  final int? stockQuantity;

  Item({
    this.name,
    this.stockQuantity,
  });
}

class Invoice {
  final double? amount;
  final String? createdAt;

  Invoice({
    this.amount,
    this.createdAt,
  });
}

class Appointment {
  final String? reason;
  final String? appointmentDate;
  final String? duration;

  Appointment({
    this.reason,
    this.appointmentDate,
    this.duration,
  });
}