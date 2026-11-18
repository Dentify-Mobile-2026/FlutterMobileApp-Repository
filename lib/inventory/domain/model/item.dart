class Item {
  final int id;
  final String name;
  final double price;
  final int stockQuantity;
  final bool isActive;
  final String category;

  Item(
    {
      required this.id,
      required this.name,
      required this.price,
      required this.stockQuantity,
      required this.isActive,
      required this.category
    }
  );
}