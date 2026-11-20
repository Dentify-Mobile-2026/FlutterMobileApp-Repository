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

bool? readBool(Object? value) {
  if (value is bool) return value;
  if (value is String) {
    final text = value.trim().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
  }
  return null;
}

/// Textos no vacíos de una lista JSON, sin repetidos y en el orden recibido.
List<String> readStringList(Object? value) {
  if (value is! List) return const [];
  final result = <String>[];
  for (final item in value) {
    final text = item is String ? readString(item) : null;
    if (text != null && !result.contains(text)) result.add(text);
  }
  return List.unmodifiable(result);
}
