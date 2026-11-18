import 'package:dentify_flutter/inventory/data/remote/dto/item_request.dart';
import 'package:dentify_flutter/inventory/domain/model/item.dart';
import 'package:dentify_flutter/inventory/domain/usecases/add_item_use_case.dart';
import 'package:dentify_flutter/inventory/domain/usecases/delete_item_use_case.dart';
import 'package:dentify_flutter/inventory/domain/usecases/get_all_items_use_case.dart';
import 'package:dentify_flutter/inventory/domain/usecases/update_item_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemViewModel extends StateNotifier<List<Item>> {
  final GetAllItemsUseCase getAllItemsUseCase;
  final DeleteItemUseCase deleteItemUseCase;
  final AddItemUseCase addItemUseCase;
  final UpdateItemUseCase updateItemUseCase;
  String? errorMessage;

  ItemViewModel(
    this.getAllItemsUseCase,
    this.deleteItemUseCase,
    this.addItemUseCase,
    this.updateItemUseCase,
  ) : super([]) {
    getAllItems();
  }

  Future<void> getAllItems() async {
    try {
      final items = await getAllItemsUseCase();
      state = items;
    } catch (e) {
      errorMessage = e.toString();
      state = [];
      print('Error fetching items: $errorMessage');
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await deleteItemUseCase(id);
      state = state.where((item) => item.id != id).toList();
    } catch (e) {
      errorMessage = e.toString();
      print('Error deleting item: $errorMessage');
    }
  }

  Future<void> addItem(ItemRequest newItem) async {
    try {
      await addItemUseCase(newItem);
      await getAllItemsUseCase();
    } catch (e) {
      errorMessage = e.toString();
      print('Error adding item: $errorMessage');
    }
  }

  Future<void> updateItem(int id, ItemRequest newItem) async {
    try {
      await updateItemUseCase(id, newItem);
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}