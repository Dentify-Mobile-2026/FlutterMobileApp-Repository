import 'package:dentify_flutter/inventory/domain/repositories/item_repository.dart';

class DeleteItemUseCase {
  final ItemRepository _repository;

  DeleteItemUseCase(this._repository);

  Future<void> call(int id) async {
    await _repository.deleteItem(id);
  }
}