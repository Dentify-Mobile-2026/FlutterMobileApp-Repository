import 'package:dentify_flutter/inventory/data/model/log_entry_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogEntryResponse', () {
    test('maps JSON with nullable invoiceId and exposes stock delta helpers', () {
      final response = LogEntryResponse.fromJson({
        'id': 12,
        'itemId': 4,
        'itemName': 'Guantes de Nitrilo',
        'previousStock': 10,
        'newStock': 25,
        'consumedQuantity': 0,
        'reason': 'Reposición de stock',
        'invoiceId': null,
        'createdAt': '2026-11-19T14:30:00',
      });

      final domain = response.toDomain();

      expect(domain.id, 12);
      expect(domain.itemId, 4);
      expect(domain.itemName, 'Guantes de Nitrilo');
      expect(domain.previousStock, 10);
      expect(domain.newStock, 25);
      expect(domain.reason, 'Reposición de stock');
      expect(domain.invoiceId, isNull);
      expect(domain.delta, 15);
      expect(domain.isIncrease, isTrue);
      expect(domain.isDecrease, isFalse);
      expect(domain.createdAtDate, DateTime(2026, 11, 19, 14, 30));
    });

    test('identifies stock decreases properly', () {
      final domain = LogEntryResponse.fromJson({
        'id': 13,
        'itemId': 4,
        'itemName': 'Anestesia',
        'previousStock': 20,
        'newStock': 14,
        'consumedQuantity': 6,
        'reason': 'Ajuste / salida de stock',
        'invoiceId': 7,
        'createdAt': '2026-11-19T16:00:00',
      }).toDomain();

      expect(domain.invoiceId, 7);
      expect(domain.delta, -6);
      expect(domain.isIncrease, isFalse);
      expect(domain.isDecrease, isTrue);
    });
  });
}
