import 'package:dentify_flutter/inventory/presentation/view/items_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Map<String, WidgetBuilder> itemRoutes(WidgetRef ref) {
  return {
    '/items': (context) => ItemsView()
  };
}