/// Lectores defensivos para JSON del backend de pagos: nunca lanzan por tipos
/// inesperados, devuelven `null` y cada DTO decide su valor por defecto.
int? readInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

num? readNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}

String? readString(Object? value) {
  if (value == null) return null;
  final text = value is String ? value.trim() : value.toString().trim();
  return text.isEmpty ? null : text;
}
