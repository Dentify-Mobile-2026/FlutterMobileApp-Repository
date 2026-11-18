import 'package:dentify_flutter/inventory/data/remote/dto/item_request.dart';
import 'package:dentify_flutter/inventory/domain/model/item.dart';
import 'package:dentify_flutter/inventory/domain/repositories/item_repository.dart';

class AddItemUseCase {
  final ItemRepository _repository;

  AddItemUseCase(this._repository);

  Future<Item> call(ItemRequest item) {
    return _repository.createItem(item);
  }
}