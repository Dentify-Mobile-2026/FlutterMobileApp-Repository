class PaymentMethod {
  final int id;
  final String name;
  final String description;

  const PaymentMethod({
    required this.id,
    required this.name,
    this.description = '',
  });
}
