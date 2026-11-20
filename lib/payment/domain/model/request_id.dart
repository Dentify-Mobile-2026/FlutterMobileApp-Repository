import 'dart:math';

final Random _secureRandom = Random.secure();

/// Genera un UUID v4 (RFC 4122) para identificar de forma idempotente el
/// registro de un abono (`requestId`).
///
/// Toma 16 bytes de [Random.secure], fija la versión (`0100xxxx` en el byte 6)
/// y la variante (`10xxxxxx` en el byte 8) y los formatea en hexadecimal
/// minúscula como `8-4-4-4-12`. [random] solo se inyecta en pruebas.
String generateRequestId([Random? random]) {
  final source = random ?? _secureRandom;
  final bytes = List<int>.generate(16, (_) => source.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
