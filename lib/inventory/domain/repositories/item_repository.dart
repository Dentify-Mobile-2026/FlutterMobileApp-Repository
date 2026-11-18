import 'package:dentify_flutter/inventory/data/remote/dto/item_request.dart';
import 'package:dentify_flutter/inventory/domain/model/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getAllItems();
  Future<void> deleteItem(int id);
  Future<Item> createItem(ItemRequest item);
  Future<void> updateItem(int id, ItemRequest item);
}