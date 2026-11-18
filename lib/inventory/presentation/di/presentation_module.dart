import 'package:dentify_flutter/inventory/data/di/dependency_injection.dart';
import 'package:dentify_flutter/inventory/domain/model/item.dart';
import 'package:dentify_flutter/inventory/domain/usecases/add_item_use_case.dart';
import 'package:dentify_flutter/inventory/domain/usecases/delete_item_use_case.dart';
import 'package:dentify_flutter/inventory/domain/usecases/get_all_items_use_case.dart';
import 'package:dentify_flutter/inventory/domain/usecases/update_item_use_case.dart';
import 'package:dentify_flutter/inventory/presentation/viewmodel/item_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllItemsUseCaseProvider = Provider<GetAllItemsUseCase>((ref) {
  return GetAllItemsUseCase(ref.read(itemRepositoryProvider));
});

final deleteItemUseCaseProvider = Provider<DeleteItemUseCase>((ref) {
  return DeleteItemUseCase(ref.read(itemRepositoryProvider));
});

final updateItemUseCaseProvider = Provider<UpdateItemUseCase>((ref) {
  return UpdateItemUseCase(ref.read(itemRepositoryProvider));
});

final addItemUseCaseProvider = Provider<AddItemUseCase>((ref) {
  return AddItemUseCase(ref.read(itemRepositoryProvider));
});

final itemsViewModelProvider = StateNotifierProvider<ItemViewModel, List<Item>>((ref) {
  return ItemViewModel(
    ref.read(getAllItemsUseCaseProvider),
    ref.read(deleteItemUseCaseProvider),
    ref.read(addItemUseCaseProvider),
    ref.read(updateItemUseCaseProvider),
  );
});