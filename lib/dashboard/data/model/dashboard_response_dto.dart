class DashboardResponseDto {
  final List<ItemDto>? lowStockItems;
  final List<InvoiceDto>? recentPayments;
  final List<AppointmentDto>? recentAppointments;

  DashboardResponseDto({
    this.lowStockItems,
    this.recentPayments,
    this.recentAppointments,
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
    );
  }

  Map<String, dynamic> toJson() => {
        'lowStockItems': lowStockItems?.map((e) => e.toJson()).toList(),
        'recentPayments': recentPayments?.map((e) => e.toJson()).toList(),
        'recentAppointments':
            recentAppointments?.map((e) => e.toJson()).toList(),
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