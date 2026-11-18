import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/inventory/data/remote/services/item_service.dart';
import 'package:dentify_flutter/inventory/data/repository/item_repository_impl.dart';
import 'package:dentify_flutter/inventory/domain/repositories/item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemServiceProvider = Provider<ItemService>(
  (ref) {
    return ItemService(ApiConstants.baseUrl);
  }
);

final itemRepositoryProvider = Provider<ItemRepository>(
  (ref) {
    return ItemRepositoryImpl(ref.read(itemServiceProvider));
  }
);