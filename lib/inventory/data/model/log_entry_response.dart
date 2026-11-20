import 'package:dentify_flutter/inventory/domain/model/log_entry.dart';

class LogEntryResponse {
  final int id;
  final int itemId;
  final String itemName;
  final int previousStock;
  final int newStock;
  final int consumedQuantity;
  final String reason;
  final int? invoiceId;
  final String createdAt;

  const LogEntryResponse({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.previousStock,
    required this.newStock,
    required this.consumedQuantity,
    required this.reason,
    this.invoiceId,
    this.createdAt = '',
  });

  factory LogEntryResponse.fromJson(Map<String, dynamic> json) {
    return LogEntryResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      itemId: (json['itemId'] as num?)?.toInt() ?? 0,
      itemName: (json['itemName'] ?? 'Insumo').toString(),
      previousStock: (json['previousStock'] as num?)?.toInt() ?? 0,
      newStock: (json['newStock'] as num?)?.toInt() ?? 0,
      consumedQuantity: (json['consumedQuantity'] as num?)?.toInt() ?? 0,
      reason: (json['reason'] ?? 'Movimiento de stock').toString(),
      invoiceId: (json['invoiceId'] as num?)?.toInt(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }

  LogEntry toDomain() {
    return LogEntry(
      id: id,
      itemId: itemId,
      itemName: itemName,
      previousStock: previousStock,
      newStock: newStock,
      consumedQuantity: consumedQuantity,
      reason: reason,
      invoiceId: invoiceId,
      createdAt: createdAt,
    );
  }
}
