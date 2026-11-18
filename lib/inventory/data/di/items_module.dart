import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/inventory/data/remote/services/item_service.dart';
import 'package:dentify_flutter/inventory/data/repository/item_repository_impl.dart';
import 'package:dentify_flutter/inventory/domain/repositories/item_repository.dart';
import 'package:dentify_flutter/inventory/domain/usecases/get_all_items_use_case.dart';
import 'package:dentify_flutter/navigation/dentify_app.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ItemsModule {
  static ItemService provideItemService() {
    return ItemService(ApiConstants.baseUrl);
  }

  static ItemRepository provideItemRepository() {
    return ItemRepositoryImpl(provideItemService());
  }

  static GetAllItemsUseCase provideGetAllItemsUseCase() {
    return GetAllItemsUseCase(provideItemRepository());
  }

  static Widget provideItemModule(){
    return MultiProvider(
      providers: [
        Provider<ItemService>(create: (_) => provideItemService()),
        Provider<ItemRepository>(create: (_) => provideItemRepository()),
        Provider<GetAllItemsUseCase>(create: (_) => provideGetAllItemsUseCase()),
      ],
      child: const DentifyApp(),
    );
  }
}