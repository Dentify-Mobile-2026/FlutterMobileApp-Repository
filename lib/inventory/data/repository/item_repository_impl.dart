import 'package:dentify_flutter/inventory/data/remote/dto/item_request.dart';
import 'package:dentify_flutter/inventory/data/remote/services/item_service.dart';
import 'package:dentify_flutter/inventory/domain/model/item.dart';
import 'package:dentify_flutter/inventory/domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository{
  final ItemService itemService;

  ItemRepositoryImpl(this.itemService);

  @override
  Future<List<Item>> getAllItems() async {
    final itemResponses = await itemService.getAllItems();
    return itemResponses.map((response) => response.toDomain()).toList();
  }
  
  @override
  Future<void> deleteItem(int id) async {
    await itemService.deleteItem(id);
  }

  @override
  Future<Item> createItem(ItemRequest item) async {
    final createItem = await itemService.createItem(item);
    return createItem.toDomain();
  }

  @override
  Future<void> updateItem(int id, ItemRequest item) async {
    await itemService.updateItem(id, item);
  }
}