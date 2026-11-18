import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'navigation/dentify_app.dart';
import 'package:intl/date_symbol_data_local.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver = RouteObserver<PageRoute<dynamic>>();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US', null);
  runApp(
    ProviderScope(child: DentifyApp()),
  );
}
