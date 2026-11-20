class DashboardResponseDto {
  final List<ItemDto>? lowStockItems;
  final List<InvoiceDto>? recentPayments;
  final List<AppointmentDto>? recentAppointments;
  final DashboardAnalyticsDto? analytics;

  DashboardResponseDto({
    this.lowStockItems,
    this.recentPayments,
    this.recentAppointments,
    this.analytics,
  });

  factory DashboardResponseDto.fromJson(Map<String, dynamic> json) {
    return DashboardResponseDto(
      lowStockItems: (json['lowStockItems'] as List?)
          ?.map((e) => ItemDto.fromJson(e))
          .toList(),
      recentPayments: (json['recentPayments'] as List?)
          ?.map((e) => InvoiceDto.fromJson(e))
          .toList(),
      recentAppointments: (json['recentAppointments'] as List?)
          ?.map((e) => AppointmentDto.fromJson(e))
          .toList(),
      analytics: json['analytics'] is Map<String, dynamic>
          ? DashboardAnalyticsDto.fromJson(
              json['analytics'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'lowStockItems': lowStockItems?.map((e) => e.toJson()).toList(),
        'recentPayments': recentPayments?.map((e) => e.toJson()).toList(),
        'recentAppointments':
            recentAppointments?.map((e) => e.toJson()).toList(),
        if (analytics != null) 'analytics': analytics!.toJson(),
      };
}

class DashboardAnalyticsDto {
  final String month;
  final List<SpecialtyRevenueDto> revenueBySpecialty;
  final AttendanceMetricsDto attendance;
  final FinancialSummaryDto financials;

  DashboardAnalyticsDto({
    required this.month,
    required this.revenueBySpecialty,
    required this.attendance,
    required this.financials,
  });

  factory DashboardAnalyticsDto.fromJson(Map<String, dynamic> json) {
    return DashboardAnalyticsDto(
      month: (json['month'] ?? '').toString(),
      revenueBySpecialty: (json['revenueBySpecialty'] as List?)
              ?.map((e) =>
                  SpecialtyRevenueDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      attendance: json['attendance'] is Map<String, dynamic>
          ? AttendanceMetricsDto.fromJson(
              json['attendance'] as Map<String, dynamic>)
          : AttendanceMetricsDto.empty(),
      financials: json['financials'] is Map<String, dynamic>
          ? FinancialSummaryDto.fromJson(
              json['financials'] as Map<String, dynamic>)
          : FinancialSummaryDto.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'revenueBySpecialty':
            revenueBySpecialty.map((e) => e.toJson()).toList(),
        'attendance': attendance.toJson(),
        'financials': financials.toJson(),
      };
}

class SpecialtyRevenueDto {
  final String category;
  final double revenue;
  final int count;

  SpecialtyRevenueDto({
    required this.category,
    required this.revenue,
    required this.count,
  });

  factory SpecialtyRevenueDto.fromJson(Map<String, dynamic> json) {
    return SpecialtyRevenueDto(
      category: (json['category'] ?? 'GENERAL').toString(),
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'revenue': revenue,
        'count': count,
      };
}

class AttendanceMetricsDto {
  final int totalAppointments;
  final int completedCount;
  final int cancelledCount;
  final int noShowCount;
  final double attendanceRate;

  AttendanceMetricsDto({
    required this.totalAppointments,
    required this.completedCount,
    required this.cancelledCount,
    required this.noShowCount,
    required this.attendanceRate,
  });

  factory AttendanceMetricsDto.empty() => AttendanceMetricsDto(
        totalAppointments: 0,
        completedCount: 0,
        cancelledCount: 0,
        noShowCount: 0,
        attendanceRate: 0.0,
      );

  factory AttendanceMetricsDto.fromJson(Map<String, dynamic> json) {
    return AttendanceMetricsDto(
      totalAppointments: (json['totalAppointments'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      cancelledCount: (json['cancelledCount'] as num?)?.toInt() ?? 0,
      noShowCount: (json['noShowCount'] as num?)?.toInt() ?? 0,
      attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalAppointments': totalAppointments,
        'completedCount': completedCount,
        'cancelledCount': cancelledCount,
        'noShowCount': noShowCount,
        'attendanceRate': attendanceRate,
      };
}

class FinancialSummaryDto {
  final double totalCollected;
  final double pendingBalance;
  final double collectionRate;

  FinancialSummaryDto({
    required this.totalCollected,
    required this.pendingBalance,
    required this.collectionRate,
  });

  factory FinancialSummaryDto.empty() => FinancialSummaryDto(
        totalCollected: 0.0,
        pendingBalance: 0.0,
        collectionRate: 0.0,
      );

  factory FinancialSummaryDto.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryDto(
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0.0,
      collectionRate: (json['collectionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalCollected': totalCollected,
        'pendingBalance': pendingBalance,
        'collectionRate': collectionRate,
      };
}

class ItemDto {
  final int? id;
  final String? name;
  final int? stockQuantity;

  ItemDto({this.id, this.name, this.stockQuantity});

  factory ItemDto.fromJson(Map<String, dynamic> json) => ItemDto(
        id: json['id'],
        name: json['name'],
        stockQuantity: json['stockQuantity'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'stockQuantity': stockQuantity,
      };
}

class InvoiceDto {
  final int? id;
  final double? amount;
  final String? createdAt;

  InvoiceDto({this.id, this.amount, this.createdAt});

  factory InvoiceDto.fromJson(Map<String, dynamic> json) => InvoiceDto(
        id: json['id'],
        amount: (json['amount'] as num?)?.toDouble(),
        createdAt: json['createdAt'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'createdAt': createdAt,
      };
}

class AppointmentDto {
  final int? id;
  final String? appointmentDate;
  final String? reason;
  final String? duration;
  final String? createdAt;

  AppointmentDto({
    this.id,
    this.appointmentDate,
    this.reason,
    this.duration,
    this.createdAt,
  });

  factory AppointmentDto.fromJson(Map<String, dynamic> json) =>
      AppointmentDto(
        id: json['id'],
        appointmentDate: json['appointmentDate'],
        reason: json['reason'],
        duration: json['duration'],
        createdAt: json['createdAt'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'appointmentDate': appointmentDate,
        'reason': reason,
        'duration': duration,
        'createdAt': createdAt,
      };
}