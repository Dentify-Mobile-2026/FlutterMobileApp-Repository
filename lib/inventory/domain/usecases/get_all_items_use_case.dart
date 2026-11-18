import 'package:dentify_flutter/inventory/domain/model/item.dart';
import 'package:dentify_flutter/inventory/domain/repositories/item_repository.dart';

class GetAllItemsUseCase {
  final ItemRepository itemRepository;

  GetAllItemsUseCase(this.itemRepository);

  Future<List<Item>> call() {
    return itemRepository.getAllItems();
  }
}