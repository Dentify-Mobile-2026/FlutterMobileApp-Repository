import 'package:dentify_flutter/inventory/data/remote/dto/item_request.dart';
import 'package:dentify_flutter/inventory/domain/repositories/item_repository.dart';

class UpdateItemUseCase {
  final ItemRepository _repository;

  UpdateItemUseCase(this._repository);

  Future<void> call(int id, ItemRequest item) {
    return _repository.updateItem(id, item);
  }
}