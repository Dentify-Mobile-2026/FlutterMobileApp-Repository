class LogEntry {
  final int id;
  final int itemId;
  final String itemName;
  final int previousStock;
  final int newStock;
  final int consumedQuantity;
  final String reason;
  final int? invoiceId;
  final String createdAt;

  const LogEntry({
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

  int get delta => newStock - previousStock;

  bool get isIncrease => newStock > previousStock;

  bool get isDecrease => newStock < previousStock;

  DateTime? get createdAtDate => DateTime.tryParse(createdAt);
}
