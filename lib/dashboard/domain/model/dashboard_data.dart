class DashboardData {
  final List<Item>? lowStockItems;
  final List<Invoice>? recentPayments;
  final List<Appointment>? recentAppointments;

  DashboardData({
    this.lowStockItems,
    this.recentPayments,
    this.recentAppointments,
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