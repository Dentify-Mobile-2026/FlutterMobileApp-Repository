import 'package:flutter/foundation.dart';

/// Monto monetario inmutable en soles, almacenado como céntimos enteros.
///
/// Nunca se usa `double` para validar ni operar montos ingresados por el
/// usuario: [Money.tryParse] trabaja directamente sobre el texto.
@immutable
class Money implements Comparable<Money> {
  /// Monto en céntimos (S/. 120.50 → 12050).
  final int cents;

  const Money.fromCents(this.cents);

  static const Money zero = Money.fromCents(0);

  /// Hasta 8 dígitos enteros y, opcionalmente, 1 o 2 decimales con `.` o `,`.
  static final RegExp _inputPattern = RegExp(r'^(\d{1,8})(?:[.,](\d{1,2}))?$');

  /// Convierte texto ingresado por el usuario ("120,5", "120.50", "35").
  /// Devuelve `null` si el formato no es válido.
  static Money? tryParse(String input) {
    final match = _inputPattern.firstMatch(input.trim());
    if (match == null) return null;
    final whole = int.parse(match.group(1)!);
    final fraction = match.group(2);
    final fractionCents =
        fraction == null ? 0 : int.parse(fraction.padRight(2, '0'));
    return Money.fromCents(whole * 100 + fractionCents);
  }

  /// Igual que [tryParse], pero lanza [FormatException] si el texto no es válido.
  factory Money.parse(String input) {
    final money = tryParse(input);
    if (money == null) {
      throw FormatException('Monto inválido', input);
    }
    return money;
  }

  /// Solo para valores numéricos que llegan del servidor (JSON).
  factory Money.fromJson(num value) => Money.fromCents((value * 100).round());

  bool get isZero => cents == 0;
  bool get isPositive => cents > 0;
  bool get isNegative => cents < 0;

  /// Representación decimal con 2 decimales y punto: `"120.50"`.
  String toApiString() {
    final absolute = cents.abs();
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '${cents < 0 ? '-' : ''}$whole.$fraction';
  }

  /// Representación para la UI: `"S/. 120.50"`.
  String format() => 'S/. ${toApiString()}';

  Money operator +(Money other) => Money.fromCents(cents + other.cents);
  Money operator -(Money other) => Money.fromCents(cents - other.cents);

  bool operator <(Money other) => cents < other.cents;
  bool operator <=(Money other) => cents <= other.cents;
  bool operator >(Money other) => cents > other.cents;
  bool operator >=(Money other) => cents >= other.cents;

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => format();
}
