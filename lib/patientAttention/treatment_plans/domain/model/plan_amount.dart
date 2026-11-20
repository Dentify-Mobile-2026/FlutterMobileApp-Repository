/// Money is stored as integer cents so quotes never accumulate double errors.
class PlanAmount {
  final int cents;
  const PlanAmount(this.cents);

  static PlanAmount? tryParse(String input) {
    final text = input.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d{1,9}(\.\d{1,2})?$').hasMatch(text)) return null;
    final parts = text.split('.');
    return PlanAmount(int.parse(parts.first) * 100 +
        (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'))));
  }

  factory PlanAmount.fromJson(dynamic value) {
    final text = value is num ? value.toStringAsFixed(2) : value.toString();
    final parts = text.split('.');
    return PlanAmount(int.parse(parts[0]) * 100 +
        (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'))));
  }

  String get decimal =>
      '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
  String get formatted => 'S/. $decimal';
}
